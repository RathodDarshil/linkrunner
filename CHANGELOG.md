## 4.0.1

- Exposed ad-network attribution fields in attribution data: `adNetworkCampaignId`, `adSetId`, `adSetName`, `adCreativeId`, `adCreativeName`.
- Bumped native Android SDK to `io.linkrunner:android-sdk:4.0.1` and native iOS SDK to `LinkrunnerKit 4.0.1`.

## 4.0.0

- **Breaking:** `paymentId` is now required in `capturePayment`; the call throws before dispatch when it is missing
- Bumped native Android SDK to `io.linkrunner:android-sdk:4.0.0`
- Bumped native iOS SDK to `LinkrunnerKit 4.0.0`

## 3.10.0

- Added `setCustomerUserId(userId)` method to attach your own user identifier to the device after `init()` — once set, the id is stored on-device and automatically included in every `trackEvent` call, so you no longer need to pass it on each event. Throws if the id is empty.
- Bumped native Android SDK to `io.linkrunner:android-sdk:3.9.1` and native iOS SDK to `LinkrunnerKit 3.11.0` for native `user_id` auto-attach support

## 3.9.1

- Bumped native Android SDK to `io.linkrunner:android-sdk:3.8.1` — token, signature key id, and signature secret key are now encrypted at rest in SharedPreferences using AES-256-GCM with a hardware-backed AndroidKeyStore key (StrongBox when available); legacy plaintext keys from prior versions are wiped atomically on the first `init()` after upgrade

## 3.9.0

- Added `handleDeeplink()` method for re-engagement attribution tracking

## 3.8.0

- Added support for Netcore device GUID (netcoreDeviceGuid) field in user data collection

## 3.7.0

- Added eventData parameter to capture payment method to support meta commerce event manager


## 3.6.3

- Added support for Google Analytics Session ID (gaSessionId) field in user data collection

## 3.6.2

- Added support for Meta view through attribution

## 3.6.1

- Upgraded the native android version to fix obfuscation errors due to TypeToken class

## 3.6.0

- Upgraded the native iOS version to support apple search ads attribution

## 3.5.1

- Removed unused dependencies and modules

## 3.5.0

- Added support to pass disableAaid flag to Android SDK

## 3.4.0

- Added support to pass disableIdfa flag to iOS SDK

## 3.3.0

-   Added Braze device ID and Google Analytics app instance ID fields to user data collection

## 3.2.1

-   Added `setPushToken()` function for push notification tracking
-   Added Android backup configuration files for proper data handling
-   Enhanced SDK initialization with platform and version parameters
-   Updated native SDK dependencies (iOS LinkrunnerKit to 3.2.0)
-   Removed deprecated `getVersion()` method
-   Improved cross-platform consistency and code cleanup

## 3.0.1

-   Flutter package for Linkrunner.io
