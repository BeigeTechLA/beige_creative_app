import 'package:flutter/foundation.dart';

/// Represents a single commission transaction in the affiliate history.
@immutable
class AffiliateTransaction {
  const AffiliateTransaction({
    required this.id,
    this.title = '',
    required this.date,
    required this.amount,
    required this.status,
    this.commission,
    this.payoutStatus,
  });

  final String id;
  final String title;
  final DateTime date;
  final double amount;

  /// One of: `completed`, `pending`, `cancelled`
  final String status;

  final double? commission;
  final String? payoutStatus;

  double get effectiveCommission => commission ?? (amount * 0.10);
  String get effectivePayoutStatus => payoutStatus ?? status;

  factory AffiliateTransaction.fromJson(Map<String, dynamic> json) {
    return AffiliateTransaction(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      commission: (json['commission'] as num?)?.toDouble(),
      payoutStatus: json['payout_status'] as String?,
    );
  }
}
