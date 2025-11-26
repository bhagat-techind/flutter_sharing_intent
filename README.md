# flutter_sharing_intent

A flutter plugin that allow flutter apps to receive photos, videos, text, urls or any other file types from another app.

## Features

- It's allow to share image, text, video, urls and file from other app to flutter app.
- It's allow to share multiple image, multiple video and multiple file from other app to flutter app.

## Installing

command:

```dart
 $ flutter pub add flutter_sharing_intent
```

pubspec.yaml:

```dart
dependencies:
flutter_sharing_intent: ^(latest)
```

## Usage

We are using following methods :-

- getMediaStream() \* => Sets up a broadcast stream for receiving incoming media share change events.
- getInitialSharing() \* => To get sharing data when app is start.
- reset() \* => To clear all sharing data

## Setup

### Android

android/app/src/main/manifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="{YOUR_PACKAGE_NAME}">

    /// Add this permission if you want to read files from external storage
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
.....

  <application
        android:name="io.flutter.app.FlutterApplication"
        ...
        >

    <activity
            android:name=".MainActivity"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:exported="true"
            android:theme="@style/LaunchTheme"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize"
            android:screenOrientation="portrait"
            android:launchMode="singleTask">

            <!--TODO:  Add this filter, if you want support opening urls into your app-->
            <intent-filter>
               <action android:name="android.intent.action.VIEW" />
               <category android:name="android.intent.category.DEFAULT" />
               <category android:name="android.intent.category.BROWSABLE" />
               <data
                   android:scheme="https"
                   android:host="example.com"
                   android:pathPrefix="/invite"/>
            </intent-filter>

            <!--TODO: Add this filter, if you want to support sharing text into your app-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="text/*" />
            </intent-filter>

            <!--TODO: Add this filter, if you want to support sharing images into your app-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="image/*" />
            </intent-filter>

            <!--TODO: Add this filter, if you want to support sharing multi images into your app-->
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="image/*" />
            </intent-filter>

            <!--TODO: Add this filter, if you want to support sharing videos into your app-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="video/*" />
            </intent-filter>

            <!--TODO: Add this filter, if you want to support sharing multi videos into your app-->
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="video/*" />
            </intent-filter>


            <!--TODO: Add this filter, if you want to support sharing any type of files-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="*/*" />
            </intent-filter>

            <!--TODO: Add this filter, if you want to support sharing multiple files of any type-->
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="*/*" />
            </intent-filter>
      </activity>

  </application>
</manifest>
....
```

## IOS

#### 1. Add the following

ios/Runner/info.plist

```xml
...
<key>AppGroupId</key>
<string>$(CUSTOM_GROUP_ID)</string> 
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>SharingMedia-$(PRODUCT_BUNDLE_IDENTIFIER)</string>
			</array>
		</dict>
	</array>

<key>NSPhotoLibraryUsageDescription</key>
<string>To upload photos, please allow permission to access your photo library.</string>
...
```

#### 2. Add Runner and Share Extension in the same group

* Go to `Signing & Capabilities` tab and add App Groups capability in **BOTH** Targets: `Runner` and `Share Extension`
* Add a new container with the name of your choice. For example `group.MyContainer` in the example project its `group.com.techind.flutterSharingIntentExample`
* Add User-defined(`Build Settings -> +`) string `CUSTOM_GROUP_ID` in **BOTH** Targets: `Runner` and `Share Extension` and set value to group id created above. You can use different group ids depends on your flavor schemes


##### Make sure the deployment target for Runner.app and the share extension is the same.


#### 3. Add the following code:

ios/Share Extension/info.plist

```xml
....
	<key>NSExtension</key>
    <dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>PHSupportedMediaTypes</key>
        <array>
            <!-- To share video into your app-->
            <string>Video</string>
            <!-- To share images into your app-->
            <string>Image</string>
        </array>

        <key>NSExtensionActivationRule</key>
        <dict>
            <!-- To share text into your app -->
            <key>NSExtensionActivationSupportsText</key>
            <true/>
            <!-- TO share urls into your app -->
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
            <integer>1</integer>
            <!-- To share images into your app -->
            <key>NSExtensionActivationSupportsImageWithMaxCount</key>
            <integer>20</integer>
            <!-- To share video into your app -->
            <key>NSExtensionActivationSupportsMovieWithMaxCount</key>
            <integer>10</integer>
            <!-- To share other files into your app -->
            <key>NSExtensionActivationSupportsFileWithMaxCount</key>
            <integer>10</integer>
        </dict>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
    </dict>
....
```


#### 4. Add the following to your [ios/Runner/Runner.entitlements](./example/ios/Runner/Runner.entitlements):


```xml
....
    <!--TODO:  Add this tag-->
    <key>com.apple.security.application-groups</key>
    <array>
    <string>group.com.techind.flutterSharingIntentExample</string>
    </array>
....
```

Here `group.com.techind.flutterSharingIntentExample` is the App Group ID created in previous step.

#### 5. Add the following to your [ios/Share Extension/FSIShareViewController.swift](./example/ios/Share%20Extension/FSIShareViewController.swift):


##### Make your `ShareViewController`  [ios/Share Extension/ShareViewController.swift](./example/ios/Share%20Extension/ShareViewController.swift) inherit from `FSIShareViewController`:

```swift

class ShareViewController: RSIShareViewController {
      
    // Use this method to return false if you don't want to redirect to host app automatically.
    // Default is true
    override func shouldAutoRedirect() -> Bool {
        return false
    }
    
}
```

#### 6. Add following code in your host app AppDelegate file

ios/Runner/AppDelegate.swift

```swift
    import flutter_sharing_intent
    ....
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

     let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
     /// if the url is made from SwiftFlutterSharingIntentPlugin then handle it with plugin [SwiftFlutterSharingIntentPlugin]
     if sharingIntent.hasSameSchemePrefix(url: url) {
         return sharingIntent.application(app, open: url, options: options)
     }

     // Proceed url handling for other Flutter libraries like uni_links
     return super.application(app, open: url, options:options)
   }
    ....
```

## Full Example

```dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;
  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream()
        .listen((List<SharedFile> value) {
      setState(() {
        list = value;
      });
      print("Shared: getMediaStream ${value.map((f) => f.value).join(",")}");
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
      print("Shared: getInitialMedia ${value.map((f) => f.value).join(",")}");
      setState(() {
        list = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Sharing data: \n${list?.join("\n\n")}\n')),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
```

## Troubleshooting

* Error: No such module 'flutter_sharing_intent'
  *  Fix: Go to Build Phases of your Runner target and move `Embed Foundation Extension` to the top of `Thin Binary`.


* Error: App does not build after adding Share Extension?
  * Fix: Check Build Settings of your share extension and remove everything that tries to import Cocoapods from your main project. i.e. remove everything under `Linking/Other Linker Flags` 

* You might need to disable bitcode for the extension target

* Error: Invalid Bundle. The bundle at 'Runner.app/Plugins/Sharing Extension.appex' contains disallowed file 'Frameworks'
    * Fix: https://stackoverflow.com/a/25789145/2061365