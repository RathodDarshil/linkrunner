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

  Future<void> init(String token,
      [String? secretKey, String? keyId, bool debug = false]) async {
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

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      await LinkRunnerNativeBridge.trackEvent(
          eventName: eventName, eventData: eventData);

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
}
