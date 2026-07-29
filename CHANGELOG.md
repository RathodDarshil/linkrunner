## 4.2.0

- Added `enableTCFConsentCollection(enabled)`, which derives the Google Ads consent state from an IAB TCF v2.2/v2.3 Consent Management Platform instead of requiring `setConsent`. The native SDK reads the CMP's standard `IABTCF_*` keys and applies Google's published purpose mapping. Anything you set explicitly with `setConsent` still wins, per signal.
- It is opt-in rather than automatic because interpreting a TC string on your behalf is a legal judgement. Only enable it if you use a TCF-compliant CMP: custom consent screens and Firebase Consent Mode do not write those keys.
- Not persisted, so call it on every launch before `init`. iOS only, matching the React Native SDK: the native Android SDK has no TCF support, so on Android the call logs and returns rather than failing on a missing method channel handler.

## 4.1.0

- Added support for Google Integrated Conversion Measurement (ICM) on iOS. The native SDK fetches Google's On-Device Measurement value during initialization and forwards it to Linkrunner. There is no Dart API to call, but ICM is **opt-in**: it stays inactive until you add Google's SDK to your app (see below). ICM is iOS-only for now; Android is unaffected.
- **To enable ICM on iOS**, add Google's On-Device Measurement SDK to your app's `ios/Podfile`:

  ```ruby
  pod 'GoogleAdsOnDeviceConversion'
  ```

  If your app already uses the Firebase iOS SDK (11.14.0+) you have it and need nothing further. LinkrunnerKit detects the SDK at runtime rather than depending on it, so apps that skip this carry none of its weight — no extra dependency, no size increase. CocoaPods adds the required `-ObjC` and `-lc++` linker flags for you, so Flutter apps have no Build Settings changes to make. To confirm it is live, initialize with `debug: true` and look for `odm_available=true` in the iOS logs; `odm_available=false` means Google's SDK is not linked.
- Bumped native iOS SDK to `LinkrunnerKit 4.1.0` (ICM plus the consent model) and native Android SDK to `io.linkrunner:android-sdk:4.1.0` (consent model only).
- Fixed the iOS podspec version, which had drifted to `3.4.0` while `pubspec.yaml` was on `4.0.1`. Both now track the package version.
- `setConsent(LRConsent(...))` for Google Ads consent: `isEEA`, `hasConsentForDataUsage` and `hasConsentForAdsPersonalization`, each `ConsentStatus.GRANTED` / `.DENIED` / `.UNKNOWN` (field names match the native iOS and Android SDKs; they are sent as `is_eea`, `ad_user_data` and `ad_personalization`). Call it before `init` and again whenever your CMP state changes. Omitted signals default to `.UNKNOWN` and are dropped from the payload rather than sent as a denial. Supported on iOS and Android.

## 4.0.3

- Bumped the native Android SDK to `io.linkrunner:android-sdk:4.0.2` to prevent signup from sending an empty install instance ID when it runs concurrently with initialization.

## 4.0.2

- Fixed `setAdditionalData` on Android by aligning the native bridge argument key with Flutter and iOS.

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
