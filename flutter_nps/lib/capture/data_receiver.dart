import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataReceiver {
  static const platform = MethodChannel('com.example.myapplication/data');

  static Future<Map<String, dynamic>?> getDataFromNative() async {
    try {
      final result = await platform.invokeMethod('sendData');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting data: $e');
      return null;
    }
  }
}
