import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'android_system_chrome_platform_interface.dart';

/// An implementation of [AndroidSystemChromePlatform] that uses method channels.
class MethodChannelAndroidSystemChrome extends AndroidSystemChromePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('android_system_chrome');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
