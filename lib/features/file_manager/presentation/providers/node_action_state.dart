import 'package:flutter/foundation.dart';

/// Per-action signal payload surfaced to widgets via `ref.listen`. Carries
/// either a success message or an error so the screen can pop the right
/// snackbar without inspecting full state.
enum FmActionSignalKind { shareCopied, deleted, downloaded, error }

@immutable
class FmActionSignal {
  final FmActionSignalKind kind;
  final String message;

  const FmActionSignal({required this.kind, required this.message});
}

/// Action-flight bookkeeping. The notifier mutates these sets so widgets
/// can disable buttons or show per-row spinners.
@immutable
class NodeActionState {
  final Set<String> sharingIds;
  final Set<String> deletingIds;
  final Map<String, double> downloadProgress;
  final FmActionSignal? lastSignal;

  const NodeActionState({
    this.sharingIds = const <String>{},
    this.deletingIds = const <String>{},
    this.downloadProgress = const <String, double>{},
    this.lastSignal,
  });

  bool isSharing(String id) => sharingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);
  bool isDownloading(String id) => downloadProgress.containsKey(id);

  NodeActionState copyWith({
    Set<String>? sharingIds,
    Set<String>? deletingIds,
    Map<String, double>? downloadProgress,
    FmActionSignal? lastSignal,
    bool clearSignal = false,
  }) {
    return NodeActionState(
      sharingIds: sharingIds ?? this.sharingIds,
      deletingIds: deletingIds ?? this.deletingIds,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      lastSignal: clearSignal ? null : (lastSignal ?? this.lastSignal),
    );
  }
}
