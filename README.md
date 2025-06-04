# linkrunner

Flutter Package for [linkrunner.io](https://www.linkrunner.io)

## Table of Contents

-   [Installation](#installation)
    -   [Step 1: Installing linkrunner](#step-1-installing-linkrunner)
    -   [Step 2: Android updates](#step-2-android-updates)
-   [Usage](#usage)
    -   [Initialisation](#initialisation)
    -   [Signup](#signup)
    -   [Get Attribution Data](#get-attribution-data)
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

Note: The init call is now fire-and-forget. To get the attribution data and the deeplink use `getAttributionData`.

```dart
import 'package:linkrunner/main.dart';

// Initialize the package
final linkrunner = LinkRunner();

void main() async {
    // Call the .ensureInitialized method before calling the .init method
    WidgetsFlutterBinding.ensureInitialized();

    await lr.init("YOUR_PROJECT_TOKEN");
    runApp(MyApp());
}
```

### Signup

Call this function only once after the user has completed the onboarding process in your app. This should be triggered at the final step of your onboarding flow to register the user with Linkrunner.

```dart
import 'package:linkrunner/main.dart';

void signup() async {
    await linkrunner.signup(
        userData: LRUserData(
                id: '1',
                name: 'John Doe', // optional
                phone: '9583849238', // optional
                email: 'support@linkrunner.io', //optional
            ),
        data: {}, // Any other data you might need
    );
  }

```

You can pass any additional user related data in the `data` attribute. This method doesn't return any value but may throw exceptions if there's an error during the signup process.

### Get Attribution Data

Use this method to retrieve attribution data for the current installation. This can be called at any point after initialization to get information about the deeplink and campaign data.

```dart
import 'package:linkrunner/main.dart';

void getAttribution() async {
    try {
        final attributionData = await linkrunner.getAttributionData();
        if (attributionData != null) {
            // Use the attribution data
            print('Installation source: ${attributionData.attributionSource}');
            print('Campaign name: ${attributionData.campaignData.name}');
        }
    } catch (e) {
        // Handle error
        print('Failed to get attribution data: $e');
    }
}
```

#### Response type for `linkrunner.getAttributionData`

```dart
{
  deeplink: String,  // The deep link that led to the installation
  attributionSource: String,  // Source of the attribution (e.g., 'ORGANIC', 'INORGANIC')
  campaignData: {
    id: String,  // Campaign ID
    name: String,  // Campaign name
    type: String,  // 'ORGANIC' or 'INORGANIC'
    adNetwork: String?,  // e.g., 'META', 'GOOGLE', or null
    groupName: String?,  // Ad group name or null
    assetGroupName: String?,  // Asset group name or null
    assetName: String?,  // Asset name or null
    installedAt: String,  // ISO 8601 timestamp of installation
    storeClickAt: String  // ISO 8601 timestamp of store click
  }
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
| [`linkrunner.getAttributionData`](#get-attribution-data)                    | In the attribution handling logic                                      | Anytime you need attribution data                       |
| [`linkrunner.setUserData`](#set-user-data)                                  | In your authentication logic                                           | Every time the app is opened and the user is logged in   |
| [`linkrunner.triggerDeeplink`](#trigger-deeplink-for-deferred-deep-linking) | After navigation initialization                                        | Once after your navigation is ready to handle deep links |
| [`linkrunner.trackEvent`](#track-event)                                     | Throughout your app where events need to be tracked                    | When specific user actions or events occur               |
| [`linkrunner.capturePayment`](#capture-revenue)                             | In your payment processing flow                                        | When a user makes a payment                              |
| [`linkrunner.removePayment`](#remove-captured-payment-revenue)              | In your payment cancellation/refund flow                               | When a payment needs to be removed                       |

### Facing issues during integration?

Email us at support@linkrunner.io

## License

MIT
