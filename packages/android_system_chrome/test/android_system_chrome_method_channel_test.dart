import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_system_chrome/android_system_chrome_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAndroidSystemChrome platform = MethodChannelAndroidSystemChrome();
  const MethodChannel channel = MethodChannel('android_system_chrome');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
