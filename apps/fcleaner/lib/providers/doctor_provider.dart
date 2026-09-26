import 'package:fclean/fclean.dart';
import 'package:flutter/foundation.dart';

class DoctorProvider extends ChangeNotifier {
  final _service = DoctorService(
    process: const ProcessService(),
    platform: const PlatformService(),
  );

  bool _loading = false;
  bool get loading => _loading;

  List<DoctorCheck> _checks = [];
  List<DoctorCheck> get checks => List.unmodifiable(_checks);

  int get availableCount => _checks.where((c) => c.available).length;
  int get totalCount => _checks.length;

  Future<void> run() async {
    _loading = true;
    notifyListeners();

    _checks = await _service.run();
    _loading = false;
    notifyListeners();
  }
}
