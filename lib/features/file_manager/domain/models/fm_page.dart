import 'package:flutter/foundation.dart';

/// One page of a cursor-paginated listing.
///
/// `nextCursor == null` signals the end of the stream — the notifier stops
/// firing `loadMore` once it sees that.
@immutable
class FmPage<T> {
  final List<T> items;
  final String? nextCursor;
  final int? total;

  const FmPage({required this.items, this.nextCursor, this.total});

  bool get hasMore => nextCursor != null;
}
