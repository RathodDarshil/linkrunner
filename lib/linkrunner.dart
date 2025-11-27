import 'dart:developer' as developer;

import 'package:linkrunner/models/attribution_data.dart';
import 'package:linkrunner/models/lr_capture_payment.dart';
import 'package:linkrunner/models/lr_remove_payment.dart';

import 'constants.dart';
import 'linkrunner_native_bridge.dart';
import 'models/lr_user_data.dart';

class LinkRunner {
  static final LinkRunner _singleton = LinkRunner._internal();

  final String packageVersion = '3.1.1';

  String? token;

  LinkRunner._internal();

  factory LinkRunner() => _singleton;

  Future<AttributionData?> getAttributionData() async {
    try {
      return await LinkRunnerNativeBridge.getAttributionData();
    } catch (e) {
      developer.log(
        'Error getting attribution data',
        error: e,
        name: packageName,
      );
      rethrow;
    }
  }

  /// Initialize the LinkRunner SDK
  /// 
  /// [token] - Your LinkRunner project token (required)
  /// [secretKey] - Optional secret key for SDK signature
  /// [keyId] - Optional key ID for SDK signature
  /// [disableIdfa] - Disable IDFA collection on iOS (default: false)
  /// [debug] - Enable debug mode (default: false)
  /// 
  /// Note: To disable AAID collection on Android, use setDisableAaidCollection() method
  Future<void> init(String token,
      [String? secretKey, String? keyId, bool disableIdfa = false, bool debug = false]) async {
    if (token.isEmpty) {
      developer.log(
        'Linkrunner needs your project token to initialize!',
        name: packageName,
      );
      throw Exception('Linkrunner needs your project token to initialize!');
    }

    this.token = token;

    try {
      await LinkRunnerNativeBridge.init(
        token,
        secretKey,
        keyId,
        disableIdfa,
        debug,
        'FLUTTER',
        packageVersion,
      );
    } catch (e) {
      developer.log('Failed to initialize SDK: $e');
    }
  }

  Future<void> signup({
    required LRUserData userData,
    Map<String, dynamic>? data,
  }) async {
    try {
      await LinkRunnerNativeBridge.signup(userData: userData, data: data);

      developer.log('Linkrunner: Signup called 🔥');

      return;
    } catch (e) {
      developer.log(
        'Linkrunner: Signup failed',
        name: packageName,
        error: e,
      );

      rethrow;
    }
  }

  Future<void> setUserData({
    required LRUserData userData,
  }) async {
    try {
      await LinkRunnerNativeBridge.setUserData(userData: userData);

      developer.log('Linkrunner: User data set successfully');

      return;
    } catch (e) {
      developer.log(
        'Linkrunner: User data set failed',
        name: packageName,
        error: e,
      );
      return;
    }
  }

  Future<void> setAdditionalData({
    required Map<String, dynamic> integrationData,
  }) async {
    try {
      await LinkRunnerNativeBridge.setAdditionalData(
        integrationData: integrationData,
      );

      developer.log('Linkrunner: Additional data set successfully');

      return;
    } catch (e) {
      developer.log(
        'Linkrunner: Additional data set failed',
        name: packageName,
        error: e,
      );
      rethrow;
    }
  }

  Future<void> capturePayment({
    required LRCapturePayment capturePayment,
  }) async {
    try {
      await LinkRunnerNativeBridge.capturePayment(
          capturePayment: capturePayment);

      developer.log('Linkrunner: Payment captured successfully 💸');

      return;
    } catch (e) {
      developer.log(
        'Linkrunner: Payment captured failed',
        name: packageName,
        error: e,
      );
      return;
    }
  }

  Future<void> removePayment({
    required LRRemovePayment removePayment,
  }) async {
    try {
      await LinkRunnerNativeBridge.removePayment(removePayment: removePayment);

      return;
    } catch (e) {
      developer.log(
        'Linkrunner: Payment removed failed',
        name: packageName,
        error: e,
      );
      return;
    }
  }


  //  [eventId] - Optional event identifier. Accepts [String] or [num] (int/double).
  //  Numbers will be automatically converted to strings.
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? eventData,
    Object? eventId,
  }) async {
    try {
      String? convertedEventId;
      if (eventId != null) {
        if (eventId is num) {
          convertedEventId = eventId.toString();
        } else if (eventId is String) {
          convertedEventId = eventId;
        } else {
          convertedEventId = null;
        }
      }
      
      await LinkRunnerNativeBridge.trackEvent(
          eventName: eventName, eventData: eventData, eventId: convertedEventId);

      developer.log('Linkrunner: Event tracked successfully > $eventName');

      return;
    } catch (e) {
      developer.log(
        'Linkrunner: Event tracked failed',
        name: packageName,
        error: e,
      );

      rethrow;
    }
  }

  /// Enable or disable PII (Personally Identifiable Information) hashing
  /// When enabled, sensitive user data like name, email, and phone will be hashed using SHA-256
  /// before being sent to the server
  ///
  /// - Parameter enabled: Whether PII hashing should be enabled (defaults to true)
  Future<void> enablePIIHashing([bool enabled = true]) async {
    try {
      await LinkRunnerNativeBridge.enablePIIHashing(enabled: enabled);
      developer.log(
        'Linkrunner: PII hashing ${enabled ? 'enabled' : 'disabled'} successfully',
        name: packageName,
      );
    } catch (e) {
      developer.log(
        'Linkrunner: Failed to ${enabled ? 'enable' : 'disable'} PII hashing',
        name: packageName,
        error: e,
      );
      rethrow;
    }
  }

  /// Set the push notification token for the current device
  /// This enables LinkRunner to send push notifications to this device
  ///
  /// - Parameter pushToken: The push notification token from FCM (Android)
  /// - Throws: Exception if the push token is empty or if setting the token fails
  Future<void> setPushToken(String pushToken) async {
    if (pushToken.isEmpty) {
      developer.log(
        'Linkrunner: Push token cannot be empty',
        name: packageName,
      );
      throw Exception('Push token cannot be empty');
    }

    try {
      await LinkRunnerNativeBridge.setPushToken(pushToken: pushToken);
      developer.log(
        'Linkrunner: Push token set successfully',
        name: packageName,
      );
    } catch (e) {
      developer.log(
        'Linkrunner: Failed to set push token',
        name: packageName,
        error: e,
      );
      rethrow;
    }
  }

  /// Disable AAID (Google Advertising ID) collection on Android
  /// When disabled, the SDK will not collect or send the Google Advertising ID (GAID).
  /// This is useful for apps targeting children or families to comply with Google Play's Family Policy.
  /// 
  /// Note: This only affects Android. For iOS, use the disableIdfa parameter in init()
  /// 
  /// - Parameter disabled: Whether AAID collection should be disabled (default: true)
  Future<void> setDisableAaidCollection([bool disabled = true]) async {
    try {
      await LinkRunnerNativeBridge.setDisableAaidCollection(disabled: disabled);
      developer.log(
        'Linkrunner: AAID collection ${disabled ? 'disabled' : 'enabled'} successfully',
        name: packageName,
      );
    } catch (e) {
      developer.log(
        'Linkrunner: Failed to ${disabled ? 'disable' : 'enable'} AAID collection',
        name: packageName,
        error: e,
      );
    }
  }

  /// Check if AAID (Google Advertising ID) collection is currently disabled on Android
  /// Returns true if AAID collection is disabled, false otherwise
  /// 
  /// Note: This only affects Android. Always returns false on iOS.
  Future<bool> isAaidCollectionDisabled() async {
    try {
      return await LinkRunnerNativeBridge.isAaidCollectionDisabled();
    } catch (e) {
      developer.log(
        'Linkrunner: Failed to check AAID collection status',
        name: packageName,
        error: e,
      );
      return false;
    }
  }
}
