import 'package:fclean/fclean.dart';
import 'package:fcleaner/services/widget_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetSyncService', () {
    test('deep link navigation parsing routes to correct screens', () {
      int? navigatedIndex;
      WidgetSyncService.instance.initialize(
        navigationHandler: (index) => navigatedIndex = index,
      );

      // Deep link to scan/clean
      WidgetSyncService.instance.onNavigate?.call(1);
      expect(navigatedIndex, equals(1));

      // Deep link to doctor
      WidgetSyncService.instance.onNavigate?.call(3);
      expect(navigatedIndex, equals(3));

      // Deep link to analytics
      WidgetSyncService.instance.onNavigate?.call(2);
      expect(navigatedIndex, equals(2));

      // Deep link to dashboard
      WidgetSyncService.instance.onNavigate?.call(0);
      expect(navigatedIndex, equals(0));
    });

    test('syncCacheEntries formats data without throwing', () async {
      final dummyEntries = [
        const ScanEntry(
          path: '/Users/test/Library/Developer/Xcode/DerivedData',
          bytes: 1024 * 1024 * 500, // 500 MB
          kind: ScanEntryKind.cache,
        ),
        const ScanEntry(
          path: '/Users/test/.pub-cache',
          bytes: 1024 * 1024 * 200, // 200 MB
          kind: ScanEntryKind.cache,
        ),
      ];

      // Should complete without unhandled exception
      await expectLater(
        WidgetSyncService.instance.syncCacheEntries(dummyEntries),
        completes,
      );
    });

    test('syncScanEntries formats workspace entries without throwing', () async {
      final entries = [
        const ScanEntry(
          path: '/Users/test/projects/my_app/build',
          bytes: 1024 * 1024 * 300,
          kind: ScanEntryKind.folder,
        ),
      ];

      await expectLater(
        WidgetSyncService.instance.syncScanEntries(entries),
        completes,
      );
    });

    test('syncAfterClean resets state without throwing', () async {
      await expectLater(
        WidgetSyncService.instance.syncAfterClean(1024 * 1024 * 500),
        completes,
      );
    });
  });
}
