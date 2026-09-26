import '../models/doctor_check.dart';
import 'platform_service.dart';
import 'process_service.dart';

class DoctorService {
  const DoctorService({
    required ProcessService process,
    required PlatformService platform,
  })  : _process = process,
        _platform = platform;

  final ProcessService _process;
  final PlatformService _platform;

  Future<List<DoctorCheck>> run() async {
    final checks = <DoctorCheck>[
      await _check('Flutter SDK', 'flutter', ['--version']),
      await _check('Dart SDK', 'dart', ['--version']),
      await _check('Android SDK', 'adb', ['version']),
      await _check('CocoaPods', 'pod', ['--version']),
      await _check('Homebrew', 'brew', ['--version']),
      await _check('FVM', 'fvm', ['--version']),
    ];

    if (_platform.isMacOS) {
      checks.add(await _check('Xcode', 'xcodebuild', ['-version']));
    } else {
      checks.add(
        const DoctorCheck(
          name: 'Xcode',
          available: false,
          message: 'macOS only',
        ),
      );
    }

    return checks;
  }

  Future<DoctorCheck> _check(
    String name,
    String executable,
    List<String> args,
  ) async {
    if (!await _process.isAvailable(executable)) {
      return DoctorCheck(
        name: name,
        available: false,
        message: '$executable not found on PATH',
      );
    }

    final result = await _process.run(executable, args);
    final output =
        '${result.stdout}${result.stderr}'.trim().split('\n').firstOrNull;
    return DoctorCheck(
      name: name,
      available: result.exitCode == 0,
      message: output == null || output.isEmpty ? 'available' : output,
    );
  }
}
