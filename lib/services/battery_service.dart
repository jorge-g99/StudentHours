import 'package:flutter/services.dart';

class BatteryService {
  static const platform = MethodChannel('com.example.student_hours/battery');

  static Future<String> getBatteryLevel() async {
    try {
      final int batteryLevel = await platform.invokeMethod('getBatteryLevel');
      return 'Battery level is $batteryLevel%';
    } on PlatformException catch (e) {
      return 'Failed to get battery level: ${e.message}';
    }
  }
}
