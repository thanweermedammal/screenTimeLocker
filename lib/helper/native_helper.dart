import 'package:flutter/services.dart';

class ScreenLock {
  static const MethodChannel _adminChannel = MethodChannel("screen_lock");
  static const MethodChannel _timerChannel = MethodChannel("com.example.timer_lock/timer");
  static const EventChannel _timerStream = EventChannel("com.example.timer_lock/timer_stream");
  static const _channel = MethodChannel('com.example.yourapp/device_admin');
  static Future<void> enableAdmin() async {
    await _adminChannel.invokeMethod("enableAdmin");
  }

  static Future<bool> isAdminActive() async {
    final result = await _adminChannel.invokeMethod("isAdminActive");
    return result == true;
  }

  static Future<void> lockScreen() async {
    await _adminChannel.invokeMethod("lockScreen");
  }

  static Future<void> startNativeTimer(int seconds) async {
    try {
      await _timerChannel.invokeMethod("startTimer", {"seconds": seconds});
    } on PlatformException catch (e) {
      print("Failed to start timer: ${e.message}");
    }
  }

  // 🔥 Stream for countdown updates
  static Stream<int> get timerStream =>
      _timerStream.receiveBroadcastStream().map((event) => event as int);
}
