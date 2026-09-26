import '../models/app_config.dart';
import '../models/cleanup_target.dart';
import '../services/platform_service.dart';
import 'cleaner.dart';

class AppleCleaner extends Cleaner {
  const AppleCleaner({required this.platform, required this.config});

  final PlatformService platform;
  final AppConfig config;

  @override
  String get name => 'iOS/macOS';

  @override
  Future<List<CleanupTarget>> discover() async {
    if (!platform.isMacOS) return const [];
    final targets = <CleanupTarget>[];
    final derivedData = platform.xcodeDerivedData;
    final pods = platform.cocoaPodsCache;

    if (config.clean.xcode && derivedData != null) {
      targets.add(
        CleanupTarget(
          id: 'apple:derived-data',
          label: 'Xcode DerivedData',
          path: derivedData,
          category: CleanupCategory.apple,
        ),
      );
    }
    if (config.clean.cocoapods && pods != null) {
      targets.add(
        CleanupTarget(
          id: 'apple:cocoapods-cache',
          label: 'CocoaPods cache',
          path: pods,
          category: CleanupCategory.apple,
        ),
      );
    }
    return targets;
  }
}
