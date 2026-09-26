import '../models/app_config.dart';
import '../models/cleanup_target.dart';
import '../services/platform_service.dart';
import 'cleaner.dart';

class AndroidCleaner extends Cleaner {
  const AndroidCleaner({required this.platform, required this.config});

  final PlatformService platform;
  final AppConfig config;

  @override
  String get name => 'Android';

  @override
  Future<List<CleanupTarget>> discover() async {
    final targets = <CleanupTarget>[];
    final gradle = platform.androidGradleCache;
    final buildCache = platform.androidBuildCache;

    if (config.clean.gradle && gradle != null) {
      targets.add(
        CleanupTarget(
          id: 'android:gradle-cache',
          label: 'Gradle cache',
          path: gradle,
          category: CleanupCategory.android,
        ),
      );
    }
    if (buildCache != null) {
      targets.add(
        CleanupTarget(
          id: 'android:build-cache',
          label: 'Android build cache',
          path: buildCache,
          category: CleanupCategory.android,
        ),
      );
    }
    return targets;
  }
}
