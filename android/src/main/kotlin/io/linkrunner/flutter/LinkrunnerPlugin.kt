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
import io.linkrunner.sdk.models.response.InitResponse
import io.linkrunner.sdk.models.response.TriggerResponse

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
                if (token != null) {
                    initNativeSDK(token, result)
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
            "triggerDeeplink" -> {
                triggerDeeplink(result)
            }
            "trackEvent" -> {
                val eventName = call.argument<String>("eventName")
                val eventData = call.argument<Map<String, Any>>("eventData")
                if (eventName != null) {
                    trackEvent(eventName, eventData, result)
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
            "getVersion" -> {
                // Return the hardcoded SDK version since there's no accessor method
                // This matches the version from LinkRunner.kt
                result.success("2.1.2")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initNativeSDK(token: String, result: Result) {
        pluginScope.launch {
            try {
                val linkRunner = NativeLinkRunner.getInstance()
                nativeLinkRunner = linkRunner
                
                val initResult = linkRunner.init(context, token)

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
                        val resultMap = mutableMapOf<String, Any?>()
                        attributionData?.let { data: io.linkrunner.sdk.models.response.AttributionData ->
                            // Convert attribution data to a map that Flutter can understand
                            // First include the response-level fields
                          
                            // Then include the AttributionData fields
                            resultMap["deeplink"] = data.deeplink
                            
                            // Map campaign data using all fields from CampaignData
                            val campaignMap = mutableMapOf<String, Any?>()
                            campaignMap["id"] = data.campaignData.id
                            campaignMap["name"] = data.campaignData.name
                            campaignMap["ad_network"] = data.campaignData.adNetwork
                            campaignMap["type"] = data.campaignData.type
                            campaignMap["installed_at"] = data.campaignData.installedAt
                            campaignMap["store_click_at"] = data.campaignData.storeClickAt
                            campaignMap["group_name"] = data.campaignData.groupName
                            campaignMap["asset_name"] = data.campaignData.assetName
                            campaignMap["asset_group_name"] = data.campaignData.assetGroupName
                            
                            resultMap["campaign_data"] = campaignMap
                        }
                        result.success(resultMap)
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

    private fun triggerDeeplink(result: Result) {
        pluginScope.launch {
            try {
                val triggerResult = NativeLinkRunner.getInstance().triggerDeeplink()
                
                withContext(Dispatchers.Main) {
                    if (triggerResult.isSuccess) {
                        result.success(null)
                    } else {
                        val error = triggerResult.exceptionOrNull()
                        result.error("DEEPLINK_FAILED", error?.message ?: "Deeplink trigger failed", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("DEEPLINK_EXCEPTION", e.message, null)
                }
            }
        }
    }

    private fun trackEvent(eventName: String, eventData: Map<String, Any>?, result: Result) {
        pluginScope.launch {
            try {
                val trackResult = NativeLinkRunner.getInstance().trackEvent(eventName, eventData)
                
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
            userCreatedAt = userData["user_created_at"] as? String,
            isFirstTimeUser = userData["is_first_time_user"] as? Boolean
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}