import Flutter
import UIKit
import LinkrunnerKit

@objc
public class SwiftLinkrunnerPlugin: NSObject, FlutterPlugin {
    private var isInitialized: Bool = false
    
    @objc
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "linkrunner_native", binaryMessenger: registrar.messenger())
        let instance = SwiftLinkrunnerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    @objc
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            if let args = call.arguments as? [String: Any],
               let token = args["token"] as? String {
                let secretKey = args["secretKey"] as? String
                let keyId = args["keyId"] as? String
                let disableIdfa = args["disableIdfa"] as? Bool
                let debug = args["debug"] as? Bool ?? false
                initNativeSDK(token: token, secretKey: secretKey, keyId: keyId, disableIdfa: disableIdfa, debug: debug, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Token is required", details: nil))
            }
            
        case "getAttributionData":
            getAttributionData(result: result)
            
        case "signup":
            if let args = call.arguments as? [String: Any],
               let userData = args["userData"] as? [String: Any] {
                let data = args["data"] as? [String: Any]
                signup(userData: userData, data: data, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "User data is required", details: nil))
            }
            
        case "setUserData":
            if let args = call.arguments as? [String: Any],
               let userData = args["userData"] as? [String: Any] {
                setUserData(userData: userData, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "User data is required", details: nil))
            }
            
        case "setAdditionalData":
            if let args = call.arguments as? [String: Any],
               let integrationData = args["integrationData"] as? [String: Any] {
                setAdditionalData(integrationData: integrationData, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Integration data is required", details: nil))
            }
            
        case "trackEvent":
            if let args = call.arguments as? [String: Any],
               let eventName = args["eventName"] as? String {
                let eventData = args["eventData"] as? [String: Any]
                let eventId = args["eventId"] as? String
                trackEvent(eventName: eventName, eventData: eventData, eventId: eventId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Event name is required", details: nil))
            }
            
        case "capturePayment":
            if let args = call.arguments as? [String: Any],
               let userId = args["userId"] as? String,
               let amount = args["amount"] as? Double {
                let paymentId = args["paymentId"] as? String
                let type = args["type"] as? String ?? "DEFAULT_PAYMENT"
                let status = args["status"] as? String ?? "PAYMENT_COMPLETED"
                capturePayment(userId: userId, amount: amount, paymentId: paymentId, type: type, status: status, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "User ID and amount are required", details: nil))
            }
            
        case "removePayment":
            if let args = call.arguments as? [String: Any] {
                let userId = args["userId"] as? String
                let paymentId = args["paymentId"] as? String
                removePayment(userId: userId, paymentId: paymentId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "User ID or payment ID is required", details: nil))
            }
            
        case "isAvailable":
            result(isInitialized)
            
        case "enablePIIHashing":
            if let args = call.arguments as? [String: Any],
               let enabled = args["enabled"] as? Bool {
                enablePIIHashing(enabled: enabled, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "enabled parameter is required", details: nil))
            }
            
        case "setPushToken":
            if let args = call.arguments as? [String: Any],
               let pushToken = args["pushToken"] as? String {
                setPushToken(pushToken: pushToken, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "pushToken parameter is required", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initNativeSDK(token: String, secretKey: String?, keyId: String?, disableIdfa: Bool?, debug: Bool, result: @escaping FlutterResult) {
        Task {
            do {
                // Call appropriate init method based on available parameters
                if let secretKey = secretKey, let keyId = keyId {
                    try await LinkrunnerSDK.shared.initialize(token: token, secretKey: secretKey, keyId: keyId, disableIdfa: disableIdfa, debug: debug)
                } else {
                    try await LinkrunnerSDK.shared.initialize(token: token, disableIdfa: disableIdfa, debug: debug)
                }
                isInitialized = true
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "INIT_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func getAttributionData(result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        Task {
            do {
                let attributionData = try await LinkrunnerSDK.shared.getAttributionData()
                DispatchQueue.main.async {
                    // Use the toDictionary method from LRAttributionDataResponse
                    result(attributionData.toDictionary())
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "ATTRIBUTION_DATA_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func signup(userData: [String: Any], data: [String: Any]?, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        let userDataObj = UserData(
            id: userData["id"] as? String ?? "",
            name: userData["name"] as? String,
            phone: userData["phone"] as? String,
            email: userData["email"] as? String,
            isFirstTimeUser: userData["is_first_time_user"] as? Bool,
            userCreatedAt: userData["user_created_at"] as? String,
            mixPanelDistinctId: userData["mixpanel_distinct_id"] as? String,
            amplitudeDeviceId: userData["amplitude_device_id"] as? String,
            posthogDistinctId: userData["posthog_distinct_id"] as? String,
            brazeDeviceId: userData["braze_device_id"] as? String,
            gaAppInstanceId: userData["ga_app_instance_id"] as? String
        )
        
        Task {
            do {
                try await LinkrunnerSDK.shared.signup(userData: userDataObj, additionalData: data)
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SIGNUP_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func setUserData(userData: [String: Any], result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        // Convert Flutter dictionary to SDK's UserData (matching Android field names)
        let userDataObj = UserData(
            id: userData["id"] as? String ?? "",
            name: userData["name"] as? String,
            phone: userData["phone"] as? String,
            email: userData["email"] as? String,
            isFirstTimeUser: userData["is_first_time_user"] as? Bool,
            userCreatedAt: userData["user_created_at"] as? String,
            mixPanelDistinctId: userData["mixpanel_distinct_id"] as? String,
            amplitudeDeviceId: userData["amplitude_device_id"] as? String,
            posthogDistinctId: userData["posthog_distinct_id"] as? String,
            brazeDeviceId: userData["braze_device_id"] as? String,
            gaAppInstanceId: userData["ga_app_instance_id"] as? String
        )
        
        Task {
            do {
                try await LinkrunnerSDK.shared.setUserData(userDataObj)
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SET_USER_DATA_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func setAdditionalData(integrationData: [String: Any], result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        // Convert Flutter dictionary to SDK's IntegrationData (matching Android field names)
        let integrationDataObj = IntegrationData(
            clevertapId: integrationData["clevertap_id"] as? String
        )
        
        Task {
            do {
                try await LinkrunnerSDK.shared.setAdditionalData(integrationDataObj)
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SET_ADDITIONAL_DATA_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func trackEvent(eventName: String, eventData: [String: Any]?, eventId: String?, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        Task {
            do {
                try await LinkrunnerSDK.shared.trackEvent(eventName: eventName, eventData: eventData, eventId: eventId)
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "TRACK_EVENT_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func capturePayment(userId: String, amount: Double, paymentId: String?, type: String, status: String, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        // Convert string enum values to iOS SDK enum types
        let paymentType = LinkrunnerKit.PaymentType(rawValue: type) ?? LinkrunnerKit.PaymentType.default
        let paymentStatus = LinkrunnerKit.PaymentStatus(rawValue: status) ?? LinkrunnerKit.PaymentStatus.completed
        
        Task {
            do {
                try await LinkrunnerSDK.shared.capturePayment(
                    amount: amount,
                    userId: userId,
                    paymentId: paymentId,
                    type: paymentType,
                    status: paymentStatus
                )
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CAPTURE_PAYMENT_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func removePayment(userId: String?, paymentId: String?, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        Task {
            do {
                try await LinkrunnerSDK.shared.removePayment(
                    userId: userId ?? "",
                    paymentId: paymentId
                )
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "REMOVE_PAYMENT_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
    
    private func enablePIIHashing(enabled: Bool, result: @escaping FlutterResult) {
        LinkrunnerSDK.shared.enablePIIHashing(enabled)
        result(nil)
    }
    
    private func setPushToken(pushToken: String, result: @escaping FlutterResult) {
        guard isInitialized else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        Task {
            do {
                try await LinkrunnerSDK.shared.setPushToken(pushToken)
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SET_PUSH_TOKEN_FAILED", 
                                      message: error.localizedDescription, 
                                      details: nil))
                }
            }
        }
    }
}
