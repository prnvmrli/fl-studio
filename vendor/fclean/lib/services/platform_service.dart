import 'dart:io';

import 'package:path/path.dart' as p;

enum HostPlatform { macos, linux, windows, unknown }

class PlatformService {
  const PlatformService({
    HostPlatform? current,
    Map<String, String>? environment,
  })  : _current = current,
        _environment = environment;

  final HostPlatform? _current;
  final Map<String, String>? _environment;

  HostPlatform get current {
    final override = _current;
    if (override != null) return override;
    if (Platform.isMacOS) return HostPlatform.macos;
    if (Platform.isLinux) return HostPlatform.linux;
    if (Platform.isWindows) return HostPlatform.windows;
    return HostPlatform.unknown;
  }

  bool get isMacOS => current == HostPlatform.macos;
  bool get isLinux => current == HostPlatform.linux;
  bool get isWindows => current == HostPlatform.windows;

  Map<String, String> get environment => _environment ?? Platform.environment;

  p.Context get _path =>
      p.Context(style: isWindows ? p.Style.windows : p.Style.posix);

  String? get homeDirectory =>
      environment['HOME'] ?? environment['USERPROFILE'];

  String get tempDirectory => Directory.systemTemp.path;

  String? get pubCacheDirectory {
    final pubCache = environment['PUB_CACHE'];
    if (pubCache != null && pubCache.isNotEmpty) return pubCache;
    if (isWindows) {
      final localAppData = environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return _path.join(localAppData, 'Pub', 'Cache');
      }
    }
    final home = homeDirectory;
    return home == null ? null : _path.join(home, '.pub-cache');
  }

  String? get androidGradleCache {
    final home = homeDirectory;
    return home == null ? null : _path.join(home, '.gradle', 'caches');
  }

  String? get androidBuildCache {
    final home = homeDirectory;
    return home == null ? null : _path.join(home, '.android', 'build-cache');
  }

  String? get xcodeDerivedData {
    final home = homeDirectory;
    return home == null
        ? null
        : _path.join(home, 'Library', 'Developer', 'Xcode', 'DerivedData');
  }

  String? get cocoaPodsCache {
    final home = homeDirectory;
    return home == null
        ? null
        : _path.join(home, 'Library', 'Caches', 'CocoaPods');
  }

  String? get trashDirectory {
    final home = homeDirectory;
    if (home == null) return null;
    if (isMacOS) return _path.join(home, '.Trash');
    if (isLinux) return _path.join(home, '.local', 'share', 'Trash', 'files');
    if (isWindows) return null;
    return null;
  }
}
