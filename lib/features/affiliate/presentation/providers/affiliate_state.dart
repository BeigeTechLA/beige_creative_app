import 'package:flutter/foundation.dart';

import '../../domain/models/affiliate_summary.dart';
import '../../domain/models/affiliate_transaction.dart';

/// Immutable state for the Affiliate screen.
@immutable
class AffiliateState {
  const AffiliateState({
    this.isLoading = false,
    this.isWithdrawing = false,
    this.errorMessage,
    this.summary,
    this.transactions = const [],
  });

  final bool isLoading;
  final bool isWithdrawing;
  final String? errorMessage;
  final AffiliateSummary? summary;
  final List<AffiliateTransaction> transactions;

  bool get hasError => errorMessage != null;
  bool get hasData => summary != null;

  bool get canWithdraw =>
      !isWithdrawing &&
      summary != null &&
      (summary!.availableBalance) > 0;

  AffiliateState copyWith({
    bool? isLoading,
    bool? isWithdrawing,
    String? errorMessage,
    bool clearError = false,
    AffiliateSummary? summary,
    List<AffiliateTransaction>? transactions,
  }) {
    return AffiliateState(
      isLoading: isLoading ?? this.isLoading,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
    );
  }
}
