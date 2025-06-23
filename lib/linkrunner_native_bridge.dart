import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'models/attribution_data.dart';
import 'models/lr_capture_payment.dart';
import 'models/lr_remove_payment.dart';
import 'models/lr_user_data.dart';
import 'constants.dart';

/// Native bridge for LinkRunner SDK
/// Handles communication between Flutter and native iOS/Android SDKs
class LinkRunnerNativeBridge {
  static const MethodChannel _channel = MethodChannel('linkrunner_native');
  
  /// Initialize the native SDK with project token
  static Future<void> init(String token) async {
    try {
      var res = await _channel.invokeMethod('init', {'token': token});
      developer.log(res.toString(), name: packageName);
      developer.log('Linkrunner initialized successfully 🔥', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to initialize native SDK: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Get attribution data from native SDK
  static Future<AttributionData?> getAttributionData() async {
    try {
      final Map<dynamic, dynamic>? result = 
          await _channel.invokeMethod('getAttributionData');
      
      if (result == null) return null;
      
      return AttributionData.fromJSON(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      developer.log('Failed to get attribution data: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Trigger user signup event
  static Future<void> signup({
    required LRUserData userData,
    Map<String, dynamic>? data,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'userData': userData.toJSON(),
        'data': data ?? {},
      };
      
      await _channel.invokeMethod('signup', arguments);
      developer.log('Signup event triggered successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to trigger signup: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Set user data
  static Future<void> setUserData({required LRUserData userData}) async {
    try {
      await _channel.invokeMethod('setUserData', {
        'userData': userData.toJSON(),
      });
      developer.log('User data set successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to set user data: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Trigger deeplink for deferred deep linking
  static Future<void> triggerDeeplink() async {
    try {
      await _channel.invokeMethod('triggerDeeplink');
      developer.log('Deeplink triggered successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to trigger deeplink: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Track custom event
  static Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'eventName': eventName,
        'eventData': eventData ?? {},
      };
      
      await _channel.invokeMethod('trackEvent', arguments);
      developer.log('Event tracked successfully: $eventName', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to track event: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Capture payment
  static Future<void> capturePayment({
    required LRCapturePayment capturePayment,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'userId': capturePayment.userId,
        'amount': capturePayment.amount,
        'paymentId': capturePayment.paymentId,
        'type': capturePayment.type,
        'status': capturePayment.status,
      };
      
      await _channel.invokeMethod('capturePayment', arguments);
      developer.log('Payment captured successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to capture payment: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Remove captured payment
  static Future<void> removePayment({
    required LRRemovePayment removePayment,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'userId': removePayment.userId,
        'paymentId': removePayment.paymentId,
      };
      
      await _channel.invokeMethod('removePayment', arguments);
      developer.log('Payment removed successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to remove payment: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Check if native SDK is available
  static Future<bool> isNativeSDKAvailable() async {
    try {
      final bool result = await _channel.invokeMethod('isAvailable');
      return result;
    } on PlatformException catch (e) {
      developer.log('Native SDK not available: ${e.message}', 
          error: e, name: packageName);
      return false;
    }
  }
  
  /// Get native SDK version
  static Future<String?> getNativeSDKVersion() async {
    try {
      final String? version = await _channel.invokeMethod('getVersion');
      return version;
    } on PlatformException catch (e) {
      developer.log('Failed to get native SDK version: ${e.message}', 
          error: e, name: packageName);
      return null;
    }
  }
}