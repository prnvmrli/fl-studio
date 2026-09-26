import 'android_system_chrome_platform_interface.dart';

class AndroidSystemChrome {
  Future<String?> getPlatformVersion() {
    return AndroidSystemChromePlatform.instance.getPlatformVersion();
  }
}
