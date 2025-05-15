import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:linkrunner/helpers.dart';
import 'package:linkrunner/models/lr_capture_payment.dart';
import 'package:linkrunner/models/lr_remove_payment.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models/api.dart';
import 'models/device_data.dart';
import 'models/lr_user_data.dart';

class LinkRunner {
  static final LinkRunner _singleton = LinkRunner._internal();

  final String _baseUrl = 'https://api.linkrunner.io';
  final String packageVersion = '1.1.0';

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

  Future<InitResponse?> _initApiCall(String? link, String? source) async {
    try {
      Uri initURL = Uri.parse('$_baseUrl/api/client/init');

      final deviceData = await _getDeviceData();

      dynamic body = {
        'token': token,
        'package_version': packageVersion,
        'device_data': deviceData,
        'platform': 'FLUTTER',
        'link': link,
        'source': source,
        'install_instance_id': await getLinkRunnerInstallInstanceId(),
      };

      var response = await http.post(
        initURL,
        headers: jsonHeaders,
        body: jsonEncode(body),
      );

      var result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['msg']);
      }

      developer.log(
        'Linkrunner initialised successfully 🔥',
        name: packageName,
      );

      if (result?['data']?['deeplink'] != null) {
        await setDeeplinkURL(result['data']['deeplink']);
      }

      if (result?['data'] != null) {
        return InitResponse.fromJSON(result?['data']);
      }

      return null;
    } catch (e) {
      developer.log(
        'Error initializing Linkrunner',
        error: e,
        name: packageName,
      );

      return null;
    }
  }

  Future<InitResponse?> init(String token) async {
    if (token.isEmpty) {
      developer.log(
        'Linkrunner needs your project token to initialize!',
        name: packageName,
      );
      return null;
    }

    final appLinks = AppLinks(); // AppLinks is singleton

    this.token = token;

    appLinks.uriLinkStream.listen((uri) {
      if (uri.queryParameters.containsKey('c')) {
        _initApiCall(uri.toString(), "GENERAL");
      }
    });

    return await _initApiCall(null, null);
  }

  Future<TriggerResponse?> signup({
    required LRUserData userData,
    Map<String, dynamic>? data,
  }) async {
    if (token == null) {
      developer.log(
        'Signup failed',
        name: packageName,
        error: Exception("linkrunner token not initialized"),
      );
      return null;
    }

    Uri triggerUrl = Uri.parse('$_baseUrl/api/client/trigger');

    final body = jsonEncode({
      'token': token,
      'user_data': userData.toJSON(),
      'platform': 'FLUTTER',
      'data': {
        'device_data': await _getDeviceData(),
        ...?data,
      },
      'install_instance_id': await getLinkRunnerInstallInstanceId(),
    });

    try {
      var response = await http.post(
        triggerUrl,
        headers: jsonHeaders,
        body: body,
      );

      var result = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        developer.log(
          'Linkrunner: Signup failed',
          name: packageName,
          error: jsonEncode(result['msg']),
        );

        throw Exception(result?.msg);
      }

      if (result['data'] != null) {
        final data = TriggerResponse.fromJSON(result['data']);

        developer.log('Linkrunner: Signup called 🔥', name: packageName);

        return data;
      }

      return null;
    } catch (e) {
      developer.log(
        'Linkrunner: Signup failed',
        name: packageName,
        error: e,
      );

      return null;
    }
  }

  Future<void> triggerDeeplink() async {
    final deeplinkURL = await getDeeplinkURL();

    if (deeplinkURL != null) {
      Uri deeplinkUrl = Uri.parse(deeplinkURL);

      try {
        await launchUrl(deeplinkUrl);

        Uri deeplinkTriggeredUri =
            Uri.parse('$_baseUrl/api/client/deeplink-triggered');

        final body = jsonEncode({
          'token': token,
          'device_data': await _getDeviceData(),
          'install_instance_id': await getLinkRunnerInstallInstanceId(),
          'platform': 'FLUTTER',
        });

        try {
          await http.post(deeplinkTriggeredUri,
              headers: jsonHeaders, body: body);

          developer.log(
            'Linkrunner: Deeplink triggered successfully',
            name: packageName,
          );
        } catch (e) {
          developer.log(
            'Linkrunner: Deeplink triggered failed',
            error: e,
            name: packageName,
          );
        }
      } catch (e) {
        // Nothing
      }
    }
  }

  Future<void> setUserData({
    required LRUserData userData,
  }) async {
    if (token == null) {
      developer.log(
        'Set user data failed',
        name: packageName,
        error: Exception("Linkrunner token not initialized"),
      );
      return;
    }

    try {
      Uri setUserDataUrl = Uri.parse('$_baseUrl/api/client/set-user-data');

      final body = jsonEncode({
        'token': token,
        'user_data': userData.toJSON(),
        'platform': 'FLUTTER',
        'device_data': await _getDeviceData(),
        'install_instance_id': await getLinkRunnerInstallInstanceId(),
      });

      var response =
          await http.post(setUserDataUrl, headers: jsonHeaders, body: body);

      var result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['msg']);
      }

      developer.log(
        'Linkrunner: User data set successfully',
        name: packageName,
      );
    } catch (e) {
      developer.log(
        'Linkrunner: User data set failed',
        error: e,
        name: packageName,
      );
    }
  }

  Future<void> capturePayment({
    required LRCapturePayment capturePayment,
  }) async {
    if (token == null) {
      developer.log(
        'Trigger failed',
        name: packageName,
        error: Exception("Linkrunner token not initialized"),
      );

      return;
    }

    try {
      Uri capturePaymentUrl = Uri.parse('$_baseUrl/api/client/capture-payment');

      final body = jsonEncode({
        'token': token,
        'platform': 'FLUTTER',
        'data': {
          'device_data': await _getDeviceData(),
        },
        'payment_id': capturePayment.paymentId,
        'user_id': capturePayment.userId,
        'amount': capturePayment.amount,
        'install_instance_id': await getLinkRunnerInstallInstanceId(),
      });

      var response =
          await http.post(capturePaymentUrl, headers: jsonHeaders, body: body);

      var result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['msg']);
      }

      developer.log(
        'Linkrunner: Payment captured successfully 💸',
        name: packageName,
      );

      return;
    } catch (e) {
      developer.log(
        'Error capturing payment',
        error: e,
        name: packageName,
      );

      return;
    }
  }

  Future<void> removePayment({
    required LRRemovePayment removePayment,
  }) async {
    if (token == null) {
      developer.log(
        'Trigger failed',
        name: packageName,
        error: Exception("Linkrunner token not initialized"),
      );

      return;
    }

    try {
      Uri capturePaymentUrl =
          Uri.parse('$_baseUrl/api/client/remove-captured-payment');

      final body = jsonEncode({
        'token': token,
        'platform': 'FLUTTER',
        'data': {
          'device_data': await _getDeviceData(),
        },
        'payment_id': removePayment.paymentId,
        'user_id': removePayment.userId,
        'install_instance_id': await getLinkRunnerInstallInstanceId(),
      });

      var response =
          await http.post(capturePaymentUrl, headers: jsonHeaders, body: body);

      var result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['msg']);
      }

      developer.log(
        'Linkrunner: Payment entry removed successfully!',
        name: packageName,
      );

      return;
    } catch (e) {
      developer.log(
        'Error removing payment entry',
        error: e,
        name: packageName,
      );

      return;
    }
  }

  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? eventData,
  }) async {
    if (token == null) {
      developer.log(
        'Track event failed',
        name: packageName,
        error: Exception("Linkrunner token not initialized"),
      );
      return;
    }

    if (eventName.isEmpty) {
      developer.log(
        'Track event failed',
        name: packageName,
        error: Exception("Event name is required"),
      );
      return;
    }

    try {
      Uri captureEventUrl = Uri.parse('$_baseUrl/api/client/capture-event');

      final body = jsonEncode({
        'token': token,
        'event_name': eventName,
        'event_data': eventData,
        'platform': 'FLUTTER',
        'device_data': await _getDeviceData(),
        'install_instance_id': await getLinkRunnerInstallInstanceId(),
      });

      var response = await http.post(
        captureEventUrl,
        headers: jsonHeaders,
        body: body,
      );

      var result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['msg']);
      }

      developer.log(
        'Linkrunner: Event tracked successfully > $eventName',
        name: packageName,
      );

      return;
    } catch (e) {
      developer.log(
        'Error tracking event',
        error: e,
        name: packageName,
      );
      return;
    }
  }
}
