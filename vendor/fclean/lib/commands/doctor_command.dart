import '../services/doctor_service.dart';
import '../utils/exceptions.dart';
import 'base_command.dart';

class DoctorCommand extends FCleanCommand {
  DoctorCommand(super.context);

  @override
  String get description =>
      'Check Flutter, Dart, Android, iOS, and package manager tooling.';

  @override
  String get name => 'doctor';

  @override
  Future<int> runCommand() async {
    final doctor = DoctorService(
      process: context.process,
      platform: context.platform,
    );
    final checks = await context.terminal.withSpinner(
      'Running diagnostics',
      doctor.run,
    );

    var ok = true;
    for (final check in checks) {
      if (check.available) {
        logger.success('[OK] ${check.name}: ${check.message}');
      } else {
        ok = false;
        logger.warn('[MISSING] ${check.name}: ${check.message}', tag: 'DOCTOR');
      }
    }

    return ok ? CleanerExitCode.success.code : CleanerExitCode.unavailable.code;
  }
}
