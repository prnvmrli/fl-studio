import 'dart:io';

import '../models/app_config.dart';

class ConfigService {
  const ConfigService();

  static const fileName = 'fclean.yaml';

  Future<bool> exists({String directory = '.'}) =>
      File('$directory/$fileName').exists();

  Future<void> writeDefault({
    String directory = '.',
    bool overwrite = false,
  }) async {
    final file = File('$directory/$fileName');
    if (file.existsSync() && !overwrite) return;
    await file.writeAsString(defaultConfigContent);
  }

  Future<AppConfig> load({String directory = '.'}) async {
    final file = File('$directory/$fileName');
    if (!file.existsSync()) return AppConfig.defaults;

    final values = <String, bool>{};
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (!trimmed.contains(':') || trimmed.startsWith('#')) continue;
      final parts = trimmed.split(':');
      if (parts.length < 2) continue;
      final key = parts.first.trim();
      final value = parts.sublist(1).join(':').trim().toLowerCase();
      if (value == 'true' || value == 'false') {
        values[key] = value == 'true';
      }
    }

    return AppConfig(
      clean: CleanConfig(
        gradle: values['gradle'] ?? true,
        xcode: values['xcode'] ?? true,
        cocoapods: values['cocoapods'] ?? true,
        trash: values['trash'] ?? false,
      ),
    );
  }
}

const defaultConfigContent = '''
clean:
  gradle: true
  xcode: true
  cocoapods: true
  trash: false
''';
