#!/usr/bin/env bash
# Navigator-Push Gate
# Enforces MIGRATION_RULES.md §6.1: no raw `Navigator.push` /
# `Navigator.pushReplacement` / `Navigator.pushAndRemoveUntil` /
# `MaterialPageRoute` / `CupertinoPageRoute` inside `lib/`.
# `Navigator.pop` is allowed — drawers, dialogs, and bottom sheets still
# use it.
#
# Usage: ./tool/check_no_navigator_push.sh
# Exit code: 0 if clean, 1 if violations found.

set -uo pipefail

FAIL=0
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
NC=$'\033[0m'

PATTERN='Navigator\.(push\(|pushReplacement\(|pushAndRemoveUntil\()|MaterialPageRoute\(|CupertinoPageRoute\('

if command -v rg >/dev/null 2>&1; then
  RESULTS="$(rg -n --type dart -e "$PATTERN" lib/ || true)"
else
  RESULTS="$(grep -rnE --include='*.dart' "$PATTERN" lib/ || true)"
fi

if [[ -n "$RESULTS" ]]; then
  echo "${RED}✘ Navigator.push / MaterialPageRoute usage in lib/${NC}"
  echo "$RESULTS"
  echo
  echo "Use context.goNamed / context.pushNamed with Routes.x.name instead."
  echo "Dialogs and bottom sheets should use showDialog / showModalBottomSheet."
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo "${GREEN}✓ no raw Navigator.push / MaterialPageRoute in lib/${NC}"
fi

exit $FAIL
