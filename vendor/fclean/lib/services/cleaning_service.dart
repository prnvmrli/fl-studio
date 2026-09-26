import '../cleaners/cleaner.dart';
import '../models/cleanup_result.dart';
import '../models/cleanup_target.dart';

class CleaningService {
  const CleaningService({
    required List<Cleaner> cleaners,
    required TargetCleaner targetCleaner,
  })  : _cleaners = cleaners,
        _targetCleaner = targetCleaner;

  final List<Cleaner> _cleaners;
  final TargetCleaner _targetCleaner;

  Future<List<CleanupTarget>> discoverTargets() async {
    final targets = <CleanupTarget>[];
    for (final cleaner in _cleaners) {
      targets.addAll(await cleaner.discover());
    }
    return targets;
  }

  Future<CleanupSummary> cleanTargets(
    List<CleanupTarget> targets, {
    required bool dryRun,
  }) async {
    final results = <CleanupResult>[];
    for (final target in targets) {
      results.add(await _targetCleaner.clean(target, dryRun: dryRun));
    }
    return CleanupSummary(results);
  }
}
