import 'package:flutter_test/flutter_test.dart';
import 'package:android_system_chrome/android_system_chrome.dart';
import 'package:android_system_chrome/android_system_chrome_platform_interface.dart';
import 'package:android_system_chrome/android_system_chrome_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAndroidSystemChromePlatform
    with MockPlatformInterfaceMixin
    implements AndroidSystemChromePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AndroidSystemChromePlatform initialPlatform = AndroidSystemChromePlatform.instance;

  test('$MethodChannelAndroidSystemChrome is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAndroidSystemChrome>());
  });

  test('getPlatformVersion', () async {
    AndroidSystemChrome androidSystemChromePlugin = AndroidSystemChrome();
    MockAndroidSystemChromePlatform fakePlatform = MockAndroidSystemChromePlatform();
    AndroidSystemChromePlatform.instance = fakePlatform;

    expect(await androidSystemChromePlugin.getPlatformVersion(), '42');
  });
}
