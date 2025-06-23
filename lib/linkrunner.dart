import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:linkrunner/helpers.dart';
import 'package:linkrunner/models/attribution_data.dart';
import 'package:linkrunner/models/lr_capture_payment.dart';
import 'package:linkrunner/models/lr_remove_payment.dart';

import 'constants.dart';
import 'linkrunner_native_bridge.dart';
import 'models/device_data.dart';
import 'models/lr_user_data.dart';

class LinkRunner {
  static final LinkRunner _singleton = LinkRunner._internal();

  final String _baseUrl = 'https://api.linkrunner.io';
  final String packageVersion = '2.0.0';

  String? token;

  LinkRunner._internal();

  factory LinkRunner() => _singleton;

  Future<Map<String, dynamic>> _getDeviceData() async {
    Map<String, dynamic> deviceData = {};

    try {
      deviceData = await getDeviceData();
      deviceData['version'] = packageVersion;
    } catch (e) {
      developer.log('Failed to get device info', error: e, name: packageName);
    }

    return deviceData;
  }

  Future<AttributionData?> getAttributionData() async {
    try {
      if (token == null || token!.isEmpty) {
        throw Exception('Linkrunner needs to be initialized with a token first!');
      }

      final url = Uri.parse('$_baseUrl/api/client/attribution-data');
      final deviceData = await _getDeviceData();

      final body = {
        'token': token,
        'package_version': packageVersion,
        'device_data': deviceData,
        'platform': 'FLUTTER',
        'install_instance_id': await getLinkRunnerInstallInstanceId(),
      };

      final response = await http.post(
        url,
        headers: jsonHeaders,
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(result['msg'] ?? 'Failed to get attribution data');
      }

      if (result['data'] == null) return null;
      
      return AttributionData.fromJSON(Map<String, dynamic>.from(result['data']));
    } catch (e) {
      developer.log(
        'Error getting attribution data',
        error: e,
        name: packageName,
      );
      rethrow;
    }
  }

  Future<void> init(String token) async {
    if (token.isEmpty) {
      developer.log(
        'Linkrunner needs your project token to initialize!',
        name: packageName,
      );
      throw Exception('Linkrunner needs your project token to initialize!');
    }

    this.token = token;
    
    try {
      await LinkRunnerNativeBridge.init(token);
      developer.log('Using native SDK for init');
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

  Future<void> capturePayment({
    required LRCapturePayment capturePayment,
  }) async {
    try {
      await LinkRunnerNativeBridge.capturePayment(capturePayment: capturePayment);

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
      await LinkRunnerNativeBridge.trackEvent(eventName: eventName, eventData: eventData);

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
}
