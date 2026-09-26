import 'cleanup_target.dart';

class CleanupResult {
  const CleanupResult({
    required this.target,
    required this.bytesReclaimed,
    required this.deleted,
    this.skippedReason,
  });

  final CleanupTarget target;
  final int bytesReclaimed;
  final bool deleted;
  final String? skippedReason;
}

class CleanupSummary {
  const CleanupSummary(this.results);

  final List<CleanupResult> results;

  int get reclaimedBytes =>
      results.fold(0, (sum, item) => sum + item.bytesReclaimed);
  int get deletedCount => results.where((item) => item.deleted).length;
  int get skippedCount => results.where((item) => !item.deleted).length;
}
