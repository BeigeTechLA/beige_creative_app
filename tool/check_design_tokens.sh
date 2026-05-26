#!/usr/bin/env bash
# Design Token Gate
# Enforces the rules in docs/DESIGN_TOKENS_RULES.md.
# Exits non-zero if any locked-category violation is found in lib/ outside lib/app/.
# Run locally before pushing, or wire into CI.
#
# Usage: ./tool/check_design_tokens.sh [--strict]
#   --strict   also fail on the pending-category gates (TextStyle, EdgeInsets,
#              fontFamily, Radius.only/vertical, SizedBox, Duration). Use after
#              Phases B + C land.

set -uo pipefail

STRICT="${1:-}"
FAIL=0
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
NC=$'\033[0m'

# Args: gate_name, regex, [extra_grep_filter_regex_to_exclude]
run_gate() {
  local name="$1"
  local pattern="$2"
  local extra_exclude_regex="${3:-}"

  # Skip commented-out lines (whitespace + //)
  local hits
  if [[ -n "$extra_exclude_regex" ]]; then
    hits=$(grep -rnE "$pattern" lib --include="*.dart" 2>/dev/null \
           | grep -v "lib/app/" \
           | grep -vE ':[[:space:]]*//' \
           | grep -vE "$extra_exclude_regex" \
           | wc -l | tr -d ' ')
  else
    hits=$(grep -rnE "$pattern" lib --include="*.dart" 2>/dev/null \
           | grep -v "lib/app/" \
           | grep -vE ':[[:space:]]*//' \
           | wc -l | tr -d ' ')
  fi

  if [[ "$hits" -gt 0 ]]; then
    echo "${RED}✗${NC} $name: ${RED}$hits${NC} violation(s)"
    if [[ -n "$extra_exclude_regex" ]]; then
      grep -rnE "$pattern" lib --include="*.dart" 2>/dev/null \
        | grep -v "lib/app/" \
        | grep -vE ':[[:space:]]*//' \
        | grep -vE "$extra_exclude_regex" \
        | head -10 | sed 's/^/    /'
    else
      grep -rnE "$pattern" lib --include="*.dart" 2>/dev/null \
        | grep -v "lib/app/" \
        | grep -vE ':[[:space:]]*//' \
        | head -10 | sed 's/^/    /'
    fi
    [[ "$hits" -gt 10 ]] && echo "    ... and $((hits - 10)) more"
    FAIL=1
  else
    echo "${GREEN}✓${NC} $name"
  fi
}

# Args: label, regex, [extra_exclude_regex]   (report only, never fails)
report_gate() {
  local label="$1"
  local pattern="$2"
  local extra_exclude_regex="${3:-}"

  local hits
  if [[ -n "$extra_exclude_regex" ]]; then
    hits=$(grep -rnE "$pattern" lib --include="*.dart" 2>/dev/null \
           | grep -v "lib/app/" \
           | grep -vE ':[[:space:]]*//' \
           | grep -vE "$extra_exclude_regex" \
           | wc -l | tr -d ' ')
  else
    hits=$(grep -rnE "$pattern" lib --include="*.dart" 2>/dev/null \
           | grep -v "lib/app/" \
           | grep -vE ':[[:space:]]*//' \
           | wc -l | tr -d ' ')
  fi
  printf "  %-22s %s\n" "$label" "$hits"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Design Token Gate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${YELLOW}LOCKED${NC} (must stay at 0)"
echo "─────────────────"

run_gate "no-raw-color-literal"  'Color\(0x[0-9a-fA-F]{8}\)'
run_gate "no-material-colors"    '[^p]Colors\.' 'AppColors\.'
run_gate "no-colorcode"          'ColorCode\.'
run_gate "no-inline-box-shadow"  'BoxShadow\('
run_gate "no-raw-asset-string"   "['\"]assets/"
run_gate "no-raw-border-radius"  'BorderRadius\.circular\([0-9]'
run_gate "no-with-opacity"       'withOpacity\('

echo ""

if [[ "$STRICT" == "--strict" ]]; then
  echo "${YELLOW}STRICT${NC} (pending gates — enforced)"
  echo "─────────────────"
  run_gate "no-inline-text-style"     'TextStyle\('
  run_gate "no-raw-edge-insets"       'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]'
  run_gate "no-raw-font-family"       "fontFamily:[[:space:]]*['\"]"
  run_gate "no-raw-radius-only"       'Radius\.circular\([0-9]'
  run_gate "no-raw-sized-box-literal" 'SizedBox\([[:space:]]*(width|height):[[:space:]]*[0-9]'
  run_gate "no-raw-duration"          'Duration\((milliseconds|seconds):[[:space:]]*[0-9]'
else
  echo "${YELLOW}PENDING${NC} (report only — pass --strict to enforce)"
  echo "─────────────────"
  report_gate "inline TextStyle"  'TextStyle\('
  report_gate "raw EdgeInsets"    'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]'
  report_gate "raw fontFamily"    "fontFamily:[[:space:]]*['\"]"
  report_gate "raw Radius.only"   'Radius\.circular\([0-9]'
  report_gate "raw SizedBox"      'SizedBox\([[:space:]]*(width|height):[[:space:]]*[0-9]'
  report_gate "raw Duration"      'Duration\((milliseconds|seconds):[[:space:]]*[0-9]'
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $FAIL -eq 0 ]]; then
  echo "${GREEN}All locked gates clean.${NC}"
  exit 0
else
  echo "${RED}Design token gate FAILED.${NC} See docs/DESIGN_TOKENS_RULES.md."
  exit 1
fi
