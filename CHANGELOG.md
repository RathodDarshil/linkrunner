## 5.0.0

Payments are now sent with `trackEvent`. `capturePayment` and `removePayment` are removed.

**Added**

- `trackEvent` takes an optional `payment: EventPayment(...)`. When it is set, the event is stored as a payment and the event name becomes the payment type, so `purchase`, `subscription_renewed` or any name you already track can carry revenue.
- `EventPayment` has `amount`, `paymentId`, `currency` (3-letter ISO 4217 code such as `USD` or `INR`) and an optional `status` (`PaymentStatus`). It throws `ArgumentError` when `amount` is negative or not finite, `paymentId` is blank, or `currency` is not 3 letters. The currency is trimmed and upper-cased.
- `EventPayment` and `PaymentStatus` are exported from `package:linkrunner/main.dart`.
- `trackEvent` calls without `payment` behave exactly as before.
- Requires the bundled native SDKs Android `io.linkrunner:android-sdk:5.0.0` and iOS `LinkrunnerKit 5.0.0`.

**Removed**

- `LinkRunner().capturePayment()`, `LinkRunner().removePayment()`, `LRCapturePayment`, `LRRemovePayment` and `PaymentType`. The `models/lr_capture_payment.dart` and `models/lr_remove_payment.dart` files are gone, so import `PaymentStatus` from `package:linkrunner/main.dart` instead.
- `removePayment` has no replacement.

**Migration**

Before:

```dart
await LinkRunner().capturePayment(
  capturePayment: LRCapturePayment(
    userId: 'user_123',
    paymentId: 'order_456',
    amount: 499.0,
    type: PaymentType.FIRST_PAYMENT,
    status: PaymentStatus.PAYMENT_COMPLETED,
  ),
);
```

After:

```dart
await LinkRunner().trackEvent(
  eventName: 'first_payment',
  payment: EventPayment(
    amount: 499.0,
    paymentId: 'order_456',
    currency: 'INR',
    status: PaymentStatus.PAYMENT_COMPLETED,
  ),
);
```

`currency` is now required. The user is taken from `setCustomerUserId()` instead of a `userId` per payment, and the old `type` becomes the event name.

## 4.2.0

- `AttributionData` from `getAttributionData()` now has `gaid` and `idfa`, the advertising identifiers Linkrunner recorded the install with. Use them to join Linkrunner attribution with your own data instead of reading the identifier again on the device. Both are nullable: `gaid` is null on iOS and when no advertising ID is available on Android, and `idfa` is null on Android and when App Tracking Transparency is not authorized on iOS. Existing code compiles unchanged.
- Requires the bundled native SDKs Android 4.2.0 and iOS LinkrunnerKit 4.2.0, which add these fields.

## 4.1.2

- Fixed a fatal Android crash from `enablePIIHashing()`: `PlatformException(ENABLE_PII_HASHING_FAILED, Context not set)` reaching `PlatformDispatcher.onError`. The native Android SDK required an application context that is only set inside `init()`, so calling `enablePIIHashing()` before `init()` — or right after an un-awaited `init()` — threw, and the Dart wrapper rethrew into an app that had nothing awaiting the call. Fixed on both sides: the bundled Android SDK is now 4.1.1, where the call is safe before `init()` and the flag is persisted during initialization, and `LinkRunner.enablePIIHashing()` now logs failures instead of rethrowing, since it is a fire-and-forget configuration setter. A pre-`init()` call is also no longer silently discarded. iOS was never affected.
- `enablePIIHashing(true)` now hashes `name`, `email` and `phone` on Android. Before, the native Android SDK stored the flag but never applied it, so `signup` and `setUserData` sent those fields in plain text while iOS sent SHA-256 hashes. Android now sends the same lowercase SHA-256 hex as iOS, so the same input gives the same hash on both platforms. Nothing changes when hashing is off. The fix ships in the bundled native Android SDK 4.1.1, so there is no Dart change.

## 4.1.1

- Fixed a Swift compiler error that broke every iOS build on `4.0.1` through `4.1.0`: the iOS bridge passed an optional `paymentId` into `LinkrunnerKit.capturePayment`, which has required a non-optional `String` since LinkrunnerKit 4.0.0. Builds failed with `Value of optional type 'String?' must be unwrapped to a value of type 'String'` regardless of your Dart code. `paymentId` is now unwrapped at the method-channel boundary. No API change — `LRCapturePayment.paymentId` was already required and non-empty validated, so correct callers are unaffected. Android was never affected.

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
