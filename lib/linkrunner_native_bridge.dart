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
  /// Optionally pass the client SDK platform and version so native Android can be configured before init
  static Future<void> init(
    String token,
    String? secretKey,
    String? keyId,
    bool debug, [
    String platform = 'FLUTTER',
    String? packageVersion,
  ]) async {
    try {
      final Map<String, dynamic> arguments = {
        'token': token,
        'debug': debug,
      };
      
      // Only include secretKey and keyId if they are provided
      if (secretKey != null) {
        arguments['secretKey'] = secretKey;
      }
      if (keyId != null) {
        arguments['keyId'] = keyId;
      }
      // Provide SDK platform and version so Android can call configureSDK before init
      arguments['platform'] = platform;
      if (packageVersion != null) {
        arguments['packageVersion'] = packageVersion;
      }
      
      var res = await _channel.invokeMethod('init', arguments);
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
      final result = await _channel.invokeMethod('getAttributionData');
      
      if (result == null) {
        developer.log('Attribution data result is null', name: packageName);
        return null;
      }
      
      // Handle empty map case (when attribution data is not available)
      if (result is Map && result.isEmpty) {
        developer.log('Attribution data result is empty', name: packageName);
        return null;
      }
      
      // Recursively convert the result to Map<String, dynamic>
      final Map<String, dynamic> attributionMap = _convertToStringDynamicMap(result);
      
      return AttributionData.fromJSON(attributionMap);
    } on PlatformException catch (e) {
      developer.log('Failed to get attribution data: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    } catch (e) {
      developer.log('Failed to parse attribution data: ${e.toString()}', 
          error: e, name: packageName);
      rethrow;
    }
  }
  
  /// Recursively convert Map<Object?, Object?> to Map<String, dynamic>
  static Map<String, dynamic> _convertToStringDynamicMap(dynamic input) {
    if (input is Map) {
      final Map<String, dynamic> result = {};
      input.forEach((key, value) {
        if (key != null) {
          final String stringKey = key.toString();
          if (value is Map) {
            result[stringKey] = _convertToStringDynamicMap(value);
          } else if (value is List) {
            result[stringKey] = _convertList(value);
          } else {
            result[stringKey] = value;
          }
        }
      });
      return result;
    }
    throw ArgumentError('Input must be a Map, got: ${input.runtimeType}');
  }
  
  /// Convert List elements recursively
  static List<dynamic> _convertList(List<dynamic> input) {
    return input.map((item) {
      if (item is Map) {
        return _convertToStringDynamicMap(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
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
  
  /// Set additional integration data
  static Future<void> setAdditionalData({
    required Map<String, dynamic> integrationData,
  }) async {
    try {
      await _channel.invokeMethod('setAdditionalData', {
        'integrationData': integrationData,
      });
      developer.log('Additional data set successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to set additional data: ${e.message}', 
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
        'type': capturePayment.type?.name ?? PaymentType.DEFAULT_PAYMENT.name,
        'status': capturePayment.status?.name ?? PaymentStatus.PAYMENT_COMPLETED.name,
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

  /// Enable or disable PII (Personally Identifiable Information) hashing
  static Future<void> enablePIIHashing({required bool enabled}) async {
    try {
      await _channel.invokeMethod('enablePIIHashing', {
        'enabled': enabled,
      });
      developer.log('PII hashing ${enabled ? 'enabled' : 'disabled'} successfully', 
          name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to ${enabled ? 'enable' : 'disable'} PII hashing: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }

  /// Set push notification token for the current user
  static Future<void> setPushToken({required String pushToken}) async {
    try {
      await _channel.invokeMethod('setPushToken', {
        'pushToken': pushToken,
      });
      developer.log('Push token set successfully', name: packageName);
    } on PlatformException catch (e) {
      developer.log('Failed to set push token: ${e.message}', 
          error: e, name: packageName);
      rethrow;
    }
  }
}