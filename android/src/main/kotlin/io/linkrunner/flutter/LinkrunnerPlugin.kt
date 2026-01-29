package io.linkrunner.flutter

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// Import the native LinkRunner SDK classes
import io.linkrunner.sdk.LinkRunner as NativeLinkRunner
import io.linkrunner.sdk.models.request.UserDataRequest
import io.linkrunner.sdk.models.request.CapturePaymentRequest
import io.linkrunner.sdk.models.request.RemovePaymentRequest
import io.linkrunner.sdk.models.IntegrationData


/** LinkrunnerPlugin */
class LinkrunnerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var nativeLinkRunner: NativeLinkRunner? = null
    
    // Plugin scope for coroutines
    private val pluginScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "linkrunner_native")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                val token = call.argument<String>("token")
                val secretKey = call.argument<String>("secretKey")
                val keyId = call.argument<String>("keyId")
                val debug = call.argument<Boolean>("debug") ?: false
                val platform = call.argument<String>("platform") ?: "FLUTTER"
                val packageVersion = call.argument<String>("packageVersion")
                if (token != null) {
                    initNativeSDK(token, secretKey, keyId, debug, platform, packageVersion, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Token is required", null)
                }
            }
            "getAttributionData" -> {
                getAttributionData(result)
            }
            "signup" -> {
                val userData = call.argument<Map<String, Any>>("userData")
                val data = call.argument<Map<String, Any>>("data")
                if (userData != null) {
                    signup(userData, data, result)
                } else {
                    result.error("INVALID_ARGUMENT", "User data is required", null)
                }
            }
            "setUserData" -> {
                val userData = call.argument<Map<String, Any>>("userData")
                if (userData != null) {
                    setUserData(userData, result)
                } else {
                    result.error("INVALID_ARGUMENT", "User data is required", null)
                }
            }
            "setAdditionalData" -> {
                val IntegrationData = call.argument<Map<String, Any>>("IntegrationData")
                if (IntegrationData != null) {
                    setAdditionalData(IntegrationData, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Integration data is required", null)
                }
            }

            "trackEvent" -> {
                val eventName = call.argument<String>("eventName")
                val eventData = call.argument<Map<String, Any>>("eventData")
                val eventId = call.argument<String?>("eventId")
                if (eventName != null) {
                    trackEvent(eventName, eventData, eventId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Event name is required", null)
                }
            }
            "capturePayment" -> {
                val userId = call.argument<String>("userId")
                val amount = call.argument<Double>("amount")
                val paymentId = call.argument<String>("paymentId")
                val type = call.argument<String>("type") ?: "DEFAULT"
                val status = call.argument<String>("status") ?: "PAYMENT_COMPLETED"
                if (userId != null && amount != null) {
                    capturePayment(userId, amount, paymentId, type, status, result)
                } else {
                    result.error("INVALID_ARGUMENT", "User ID and amount are required", null)
                }
            }
            "removePayment" -> {
                val userId = call.argument<String>("userId")
                val paymentId = call.argument<String>("paymentId")
                removePayment(userId, paymentId, result)
            }
            "isAvailable" -> {
                result.success(nativeLinkRunner != null)
            }
            "enablePIIHashing" -> {
                val enabled = call.argument<Boolean>("enabled")
                if (enabled != null) {
                    enablePIIHashing(enabled, result)
                } else {
                    result.error("INVALID_ARGUMENT", "enabled parameter is required", null)
                }
            }
            "setPushToken" -> {
                val pushToken = call.argument<String>("pushToken")
                if (pushToken != null) {
                    setPushToken(pushToken, result)
                } else {
                    result.error("INVALID_ARGUMENT", "pushToken parameter is required", null)
                }
            }
            "setDisableAaidCollection" -> {
                val disabled = call.argument<Boolean>("disabled")
                if (disabled != null) {
                    setDisableAaidCollection(disabled, result)
                } else {
                    result.error("INVALID_ARGUMENT", "disabled parameter is required", null)
                }
            }
            "isAaidCollectionDisabled" -> {
                isAaidCollectionDisabled(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initNativeSDK(
        token: String,
        secretKey: String?,
        keyId: String?,
        debug: Boolean,
        platform: String,
        packageVersion: String?,
        result: Result
    ) {
        pluginScope.launch {
            try {
                val linkRunner = NativeLinkRunner.getInstance()
                nativeLinkRunner = linkRunner
                
                // Configure SDK with client platform and version prior to init
                try {
                    if (packageVersion != null) {
                        NativeLinkRunner.configureSDK(platform, packageVersion)
                    } else {
                        // fallback when version is unavailable
                        NativeLinkRunner.configureSDK(platform, "unknown")
                    }
                } catch (e: Exception) {
                    android.util.Log.w("LinkRunner", "configureSDK failed: ${e.message}")
                }

                // Call appropriate init method based on available parameters
                val initResult = if (secretKey != null && keyId != null) {
                    linkRunner.init(context, token, secretKey = secretKey, keyId = keyId, debug = debug)
                } else {
                    linkRunner.init(context, token, debug = debug)
                }

                android.util.Log.d("LinkRunner", "Init result: $initResult")
                android.util.Log.d("LinkRunner", "Is success: ${initResult.isSuccess}")
                initResult.onSuccess { response ->
                    android.util.Log.d("LinkRunner", "Init response: $response")
                }
                initResult.onFailure { error ->
                    android.util.Log.e("LinkRunner", "Init failed", error)
                }
                
                withContext(Dispatchers.Main) {
                    if (initResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = initResult.exceptionOrNull()
                        result.error("INIT_FAILED", error?.message ?: "Initialization failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("INIT_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun getAttributionData(result: Result) {
        pluginScope.launch {
            try {
                val attributionDataResult = NativeLinkRunner.getInstance().getAttributionData()
                
                withContext(Dispatchers.Main) {
                    if (attributionDataResult.isSuccess) {
                        val attributionData = attributionDataResult.getOrNull()
                        if (attributionData != null) {
                            val resultMap = mutableMapOf<String, Any?>()
                            
                            // Include the AttributionData fields with proper null safety
                            resultMap["deeplink"] = attributionData.deeplink
                            
                            // Map campaign data using all fields from CampaignData with null safety
                            val campaignMap = mutableMapOf<String, Any?>()
                            campaignMap["id"] = attributionData.campaignData.id
                            campaignMap["name"] = attributionData.campaignData.name
                            campaignMap["ad_network"] = attributionData.campaignData.adNetwork
                            campaignMap["type"] = attributionData.campaignData.type
                            campaignMap["installed_at"] = attributionData.campaignData.installedAt
                            campaignMap["store_click_at"] = attributionData.campaignData.storeClickAt
                            campaignMap["group_name"] = attributionData.campaignData.groupName
                            campaignMap["asset_name"] = attributionData.campaignData.assetName
                            campaignMap["asset_group_name"] = attributionData.campaignData.assetGroupName
                            
                            resultMap["campaign_data"] = campaignMap
                            
                            result.success(resultMap)
                        } else {
                            // Return empty map if attribution data is null
                            result.success(mapOf<String, Any?>())
                        }
                    } else {
                        val error = attributionDataResult.exceptionOrNull()
                        result.error("ATTRIBUTION_DATA_FAILED", 
                                    error?.message ?: "Failed to get attribution data", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("ATTRIBUTION_DATA_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun signup(userData: Map<String, Any>, data: Map<String, Any>?, result: Result) {
        pluginScope.launch {
            try {
                val userDataModel = convertToNativeUserData(userData)
                val signupResult = NativeLinkRunner.getInstance().signup(userDataModel, data)
                
                withContext(Dispatchers.Main) {
                    if (signupResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = signupResult.exceptionOrNull()
                        result.error("SIGNUP_FAILED", error?.message ?: "Signup failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SIGNUP_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun setUserData(userData: Map<String, Any>, result: Result) {
        pluginScope.launch {
            try {
                val userDataModel = convertToNativeUserData(userData)
                val setUserDataResult = NativeLinkRunner.getInstance().setUserData(userDataModel)
                
                withContext(Dispatchers.Main) {
                    if (setUserDataResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = setUserDataResult.exceptionOrNull()
                        result.error("SET_USER_DATA_FAILED", error?.message ?: "Set user data failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SET_USER_DATA_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun setAdditionalData(IntegrationData: Map<String, Any>, result: Result) {
        pluginScope.launch {
            try {
                val IntegrationDataModel = IntegrationData(
                    clevertapId = IntegrationData["clevertap_id"] as? String
                )
                
                val setAdditionalDataResult = NativeLinkRunner.getInstance().setAdditionalData(IntegrationDataModel)
                
                withContext(Dispatchers.Main) {
                    if (setAdditionalDataResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = setAdditionalDataResult.exceptionOrNull()
                        result.error("SET_ADDITIONAL_DATA_FAILED", error?.message ?: "Set additional data failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SET_ADDITIONAL_DATA_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun trackEvent(eventName: String, eventData: Map<String, Any>?, eventId: String?, result: Result) {
        pluginScope.launch {
            try {
                val trackResult = NativeLinkRunner.getInstance().trackEvent(eventName, eventData, eventId)
                
                withContext(Dispatchers.Main) {
                    if (trackResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = trackResult.exceptionOrNull()
                        result.error("TRACK_EVENT_FAILED", error?.message ?: "Track event failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("TRACK_EVENT_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun capturePayment(userId: String, amount: Double, paymentId: String?, type: String, status: String, result: Result) {
        pluginScope.launch {
            try {
                // Convert string to enum types
                val paymentType = try {
                    io.linkrunner.sdk.models.PaymentType.valueOf(type)
                } catch (e: IllegalArgumentException) {
                    io.linkrunner.sdk.models.PaymentType.DEFAULT
                }
                
                val paymentStatus = try {
                    io.linkrunner.sdk.models.PaymentStatus.valueOf(status)
                } catch (e: IllegalArgumentException) {
                    io.linkrunner.sdk.models.PaymentStatus.PAYMENT_COMPLETED
                }
                
                val capturePaymentRequest = CapturePaymentRequest(
                    paymentId = paymentId ?: "",
                    userId = userId,
                    amount = amount,
                    type = paymentType,
                    status = paymentStatus
                )
                
                
                val captureResult = NativeLinkRunner.getInstance().capturePayment(capturePaymentRequest)
                
                withContext(Dispatchers.Main) {
                    if (captureResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = captureResult.exceptionOrNull()
                        result.error("CAPTURE_PAYMENT_FAILED", error?.message ?: "Capture payment failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("CAPTURE_PAYMENT_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun removePayment(userId: String?, paymentId: String?, result: Result) {
        pluginScope.launch {
            try {
                val removePaymentRequest = RemovePaymentRequest(
                    paymentId = paymentId,
                    userId = userId
                )
                
                
                val removeResult = NativeLinkRunner.getInstance().removePayment(removePaymentRequest)
                
                withContext(Dispatchers.Main) {
                    if (removeResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = removeResult.exceptionOrNull()
                        result.error("REMOVE_PAYMENT_FAILED", error?.message ?: "Remove payment failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("REMOVE_PAYMENT_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun convertToNativeUserData(userData: Map<String, Any>): UserDataRequest {
        return UserDataRequest(
            id = userData["id"] as? String ?: "",
            name = userData["name"] as? String,
            email = userData["email"] as? String,
            phone = userData["phone"] as? String,
            mixpanelDistinctId = userData["mixpanel_distinct_id"] as? String,
            amplitudeDeviceId = userData["amplitude_device_id"] as? String,
            posthogDistinctId = userData["posthog_distinct_id"] as? String,
            brazeDeviceId = userData["braze_device_id"] as? String,
            gaAppInstanceId = userData["ga_app_instance_id"] as? String,
            gaSessionId = userData["ga_session_id"] as? String,
            userCreatedAt = userData["user_created_at"] as? String,
            isFirstTimeUser = userData["is_first_time_user"] as? Boolean
        )
    }

    private fun enablePIIHashing(enabled: Boolean, result: Result) {
        try {
            NativeLinkRunner.getInstance().enablePIIHashing(enabled)
            result.success(null)
        } catch (e: Exception) {
            result.error("ENABLE_PII_HASHING_FAILED", e.message, null)
        }
    }

    private fun setPushToken(pushToken: String, result: Result) {
        if (pushToken.isBlank()) {
            result.error("INVALID_ARGUMENT", "Push token cannot be empty", null)
            return
        }

        pluginScope.launch {
            try {
                val setPushTokenResult = NativeLinkRunner.getInstance().setPushToken(pushToken)
                
                withContext(Dispatchers.Main) {
                    if (setPushTokenResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = setPushTokenResult.exceptionOrNull()
                        result.error("SET_PUSH_TOKEN_FAILED", error?.message ?: "Set push token failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("SET_PUSH_TOKEN_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun setDisableAaidCollection(disabled: Boolean, result: Result) {
        try {
            NativeLinkRunner.getInstance().setDisableAaidCollection(disabled)
            android.util.Log.d("LinkRunner", "AAID collection ${if (disabled) "disabled" else "enabled"}")
            result.success(null)
        } catch (e: Exception) {
            result.error("SET_DISABLE_AAID_FAILED", e.message, null)
        }
    }

    private fun isAaidCollectionDisabled(result: Result) {
        try {
            val isDisabled = NativeLinkRunner.getInstance().isAaidCollectionDisabled()
            result.success(isDisabled)
        } catch (e: Exception) {
            result.error("IS_AAID_COLLECTION_DISABLED_FAILED", e.message, null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}