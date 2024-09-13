# linkrunner

Flutter Package for [linkrunner.io](https://www.linkrunner.io)

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
    linkrunner: ^0.7.5
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
}
```

### Trigger

Call this function once your onboarding is completed and the main stack is loaded

```dart
import 'package:linkrunner/main.dart';

void trigger() async {
    final trigger = await linkrunner.trigger(
        userData: LRUserData(
                id: '1',
                name: 'John Doe', // optional
                phone: '9583849238', // optional
                email: 'support@linkrunner.io', //optional
            ),
        data: {}, // Any other data you might need
        config: TriggerConfig(
            triggerDeeplink: true // true by default
        )
    );
  }
```

By setting config > triggerDeeplink as `true` the deeplink won't be trigged (Only set to false if you are handling the redirection by yourself)

You can pass any additional user related data in the `data` attribute

#### Response type for `linkrunner.trigger`

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
  trigger: boolean; // Deeplink won't be triggered if false
}
```

Note: Value of `trigger` will be only true for the first time the function is triggered by the user in order to prevent unnecessary redirects

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

### Additional setup for Google Ads

This setup is only needed if you are planning on running app ads via Google Ads and want to tracking them

#### Step 1

Make sure you have setup [firebase_core](https://pub.dev/packages/firebase_core) and [firebase_analytics](https://pub.dev/packages/firebase_analytics) correctly in your flutter project

#### Step 2

Update your `AndroidManifest.xml` file

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.myawesome.app">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
     android:name=".MainActivity">

     <!-- Add the below line -->
     <meta-data android:name="google_analytics_deferred_deep_link_enabled" android:value="true"/>

       <activity
            android:name=".MainActivity" >
       </activity>

    </application>

</manifest>
```

### Facing issues during integration?

Email us at support@linkrunner.io

## License

MIT
