import '../models/app_config.dart';
import '../models/cleanup_target.dart';
import '../services/platform_service.dart';
import 'cleaner.dart';

class SystemCleaner extends Cleaner {
  const SystemCleaner({required this.platform, required this.config});

  final PlatformService platform;
  final AppConfig config;

  @override
  String get name => 'System';

  @override
  Future<List<CleanupTarget>> discover() async {
    final targets = <CleanupTarget>[
      CleanupTarget(
        id: 'system:temp',
        label: 'Temporary files',
        path: platform.tempDirectory,
        category: CleanupCategory.system,
        contentsOnly: true,
      ),
    ];

    final trash = platform.trashDirectory;
    if (config.clean.trash && trash != null) {
      targets.add(
        CleanupTarget(
          id: 'system:trash',
          label: platform.isWindows ? 'Recycle bin' : 'Trash',
          path: trash,
          category: CleanupCategory.system,
          contentsOnly: true,
        ),
      );
    }

    return targets;
  }
}
