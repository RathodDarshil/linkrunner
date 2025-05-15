# linkrunner

Flutter Package for [linkrunner.io](https://www.linkrunner.io)

## Table of Contents

-   [Installation](#installation)
    -   [Step 1: Installing linkrunner](#step-1-installing-linkrunner)
    -   [Step 2: Android updates](#step-2-android-updates)
-   [Usage](#usage)
    -   [Initialisation](#initialisation)
    -   [Signup](#signup)
    -   [Set User Data](#set-user-data)
    -   [Trigger Deeplink](#trigger-deeplink-for-deferred-deep-linking)
    -   [Track Event](#track-event)
    -   [Capture revenue](#capture-revenue)
    -   [Remove captured payment revenue](#remove-captured-payment-revenue)
-   [Function Placement Guide](#function-placement-guide)
-   [License](#license)

## Installation

### Step 1: Installing linkrunner

#### Installing through cmdline

run the following:

```sh
flutter pub add linkrunner
```

#### OR

#### Manually adding dependencies

Add `linkrunner` to your `pubspec.yaml` under dependencies:

```yaml
dependencies:
    linkrunner: ^0.7.9
```

Then run:

```sh
flutter pub get
```

to install your new dependency.

### Step 2: Android updates

Add the following in `app/build.gradle` file

```
dependencies {
    ...
    implementation("com.android.installreferrer:installreferrer:2.2")
}
```

### Step 3: IOS updates

Add the following in `info.plist`:
```plist
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

## Usage

### Initialisation

You will need your [project token](https://www.linkrunner.io/dashboard?m=documentation) to initialise the package.

Place it in the `main` function:

```dart
import 'package:linkrunner/main.dart';

// Initialize the package
final linkrunner = LinkRunner();

void main() async {
    // Call the .ensureInitialized method before calling the .init method
    WidgetsFlutterBinding.ensureInitialized();

    final init = await lr.init("YOUR_PROJECT_TOKEN");
    runApp(MyApp());
}
```

#### Response type for `linkrunner.init`

```
{
  ip_location_data: {
    ip: string;
    city: string;
    countryLong: string;
    countryShort: string;
    latitude: number;
    longitude: number;
    region: string;
    timeZone: string;
    zipCode: string;
  };
  deeplink: string;
  root_domain: boolean;
  campaign_data: {
    id: string;
    name: string;
    type: "ORGANIC" | "INORGANIC";
    ad_network: "META" | "GOOGLE" | null;
    group_name: string | null;
    asset_group_name: string | null;
    asset_name: string | null;
  };
}
```

### Signup

Call this function only once after the user has completed the onboarding process in your app. This should be triggered at the final step of your onboarding flow to register the user with Linkrunner.

It is strongly recommended to use the platform’s identify function to set a persistent user_id once it becomes available (typically after signup or login).

- [Mixpanel - ID Management & User Identification](https://docs.mixpanel.com/docs/tracking-methods/id-management/identifying-users-simplified)
- [PostHog - How User Identification Works](https://posthog.com/docs/product-analytics/identify#how-identify-works)
- [Amplitude - Identify Users Documentation](https://amplitude.com/docs/get-started/identify-users)

If the platform's identifier function is not called, you must provide a user identifier for Mixpanel, PostHog, and Amplitude integration.

- mixpanel_distinct_id for Mixpanel
- posthog_distinct_id for PostHog
- amplitude_device_id for Amplitude

```dart
import 'package:linkrunner/main.dart';

void signup() async {
    final signup = await linkrunner.signup(
        userData: LRUserData(
                id: '1',
                name: 'John Doe', // optional
                phone: '9583849238', // optional
                email: 'support@linkrunner.io', //optional
                mixpanelDistinctId: '1234567890', // optional
                amplitudeDeviceId: '1234567890', // optional
                posthogDistinctId: '1234567890', // optional
            ),
        data: {}, // Any other data you might need
    );
  }
```

You can pass any additional user related data in the `data` attribute

#### Response type for `linkrunner.signup`

```
{
  ip_location_data: {
    ip: string;
    city: string;
    countryLong: string;
    countryShort: string;
    latitude: number;
    longitude: number;
    region: string;
    timeZone: string;
    zipCode: string;
  };
  deeplink: string;
  root_domain: boolean;
}
```

### Set User Data

Call this function everytime the app is opened and the user is logged in.

```dart
import 'package:linkrunner/main.dart';

void setUserData() async {
    await linkrunner.setUserData(
        userData: LRUserData(
            id: '1',
            name: 'John Doe', // optional
            phone: '9583849238', // optional
            email: 'support@linkrunner.io', //optional
            mixpanelDistinctId: '1234567890', // optional
            amplitudeDeviceId: '1234567890', // optional
            posthogDistinctId: '1234567890', // optional
        ),
    );
}
```

### Trigger Deeplink (For Deferred Deep Linking)

This function triggers the original deeplink that led to the app installation. Call it only after your main navigation is initialized and all deeplink-accessible screens are ready to receive navigation events.

Note: For this to work properly make sure you have added verification objects on the [Linkrunner Dashboard](https://www.linkrunner.io/settings?sort_by=activity-1&s=store-verification).

```dart
import 'package:linkrunner/main.dart';

void triggerDeeplink() async {
    await linkrunner.triggerDeeplink();
}
```

### Track Event

Use this method to track custom events

```dart
import 'package:linkrunner/main.dart';

void trackEvent() async {
    await linkrunner.trackEvent(
        eventName: 'event_name', // Name of the event
        eventData: { 'key': 'value' } // Optional: Additional JSON data for the event
    );
}
```

### Capture revenue

Call this function after a payment is confirmed

```dart
import 'package:linkrunner/models/lr_capture_payment.dart';

void capturePayment() async {
    await linkrunner.capturePayment(
        capturePayment: LRCapturePayment(
            userId: '666',
            amount: 24168, // Send amount in one currency only
            paymentId: 'AJKHAS' // optional but recommended
        ),
    );
  }
```

NOTE: If you accept payments in multiple currencies convert them to one currency before calling the above function

### Remove captured payment revenue

Call this function after a payment is cancelled or refunded

```dart
import 'package:linkrunner/models/lr_remove_payment.dart';

void removeCapturedPayment() async {
    await linkrunner.removePayment(
        removePayment: LRRemovePayment(
            userId: '666',
            paymentId: 'AJKHAS' // Ethier paymentId or userId is required!
        ),
    );
  }
```

NOTE: `userId` or `paymentId` is required in order to remove a payment entry, if you use userId all the payments attributed to that user will be removed

### Function Placement Guide

Below is a simple guide on where to place each function in your application:

| Function                                                                    | Where to Place                                                         | When to Call                                             |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------------------------------------------------- |
| [`linkrunner.init`](#initialisation)                                        | In your `main.dart` within a `WidgetsFlutterBinding.ensureInitialized` | Once when the app starts                                 |
| [`linkrunner.signup`](#signup)                                              | In your onboarding flow                                                | Once after user completes the onboarding process         |
| [`linkrunner.setUserData`](#set-user-data)                                  | In your authentication logic                                           | Every time the app is opened and the user is logged in   |
| [`linkrunner.triggerDeeplink`](#trigger-deeplink-for-deferred-deep-linking) | After navigation initialization                                        | Once after your navigation is ready to handle deep links |
| [`linkrunner.trackEvent`](#track-event)                                     | Throughout your app where events need to be tracked                    | When specific user actions or events occur               |
| [`linkrunner.capturePayment`](#capture-revenue)                             | In your payment processing flow                                        | When a user makes a payment                              |
| [`linkrunner.removePayment`](#remove-captured-payment-revenue)              | In your payment cancellation/refund flow                               | When a payment needs to be removed                       |

### Facing issues during integration?

Email us at support@linkrunner.io

## License

MIT
