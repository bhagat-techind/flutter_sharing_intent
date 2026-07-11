# flutter_sharing_intent
[![pub package](https://img.shields.io/pub/v/flutter_sharing_intent.svg)](https://pub.dev/packages/flutter_sharing_intent)

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

Add the following intent filters to your [android/app/src/main/AndroidManifest.xml](./example/android/app/src/main/AndroidManifest.xml):

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

> **Note:** `android:launchMode="singleTask"` is required on your `MainActivity`. Without it, Android
> creates a new activity instance for each share intent instead of routing it to the running app,
> which means `getMediaStream()` never fires for background shares. If you need a different launch
> mode for another reason, `singleTop` also works.

> **Tip – Limiting which file types appear in the share sheet:** Each `<intent-filter>` block above
> registers your app for that MIME type. Remove any filters you don't need and your app will no
> longer appear in the system share sheet for those types.  For example, to receive only images and
> videos, keep only the `image/*` and `video/*` filters and remove the others.

## IOS

#### 1. Create Share Extension

- Using Xcode, go to File/New/Target and Choose "Share Extension".
- Give it a name, i.e., "Share Extension".

Make sure the deployment target for Runner.app and the share extension is the same.

#### 2. Update your [ios/Runner/Info.plist](./example/ios/Runner/Info.plist) for the following keys:

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


#### 3. Add the following to your [ios/Podfile](./example/ios/Podfile):
```ruby
...
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Share Extension is name of Extension which you created which is in this case 'Share Extension'
  target 'Share Extension' do
    inherit! :search_paths
  end
end
...
```

#### 4. Add Runner and Share Extension in the same group

* Go to `Signing & Capabilities` tab and add App Groups capability in **BOTH** Targets: `Runner` and `Share Extension`
* Add a new container with the name of your choice. For example `group.MyContainer` in the example project its `group.com.techind.flutterSharingIntentExample`
* Add User-Defined(`Build Settings -> +`) string `CUSTOM_GROUP_ID` in **BOTH** Targets: `Runner` and `Share Extension` and set value to group id created above. You can use different group ids depends on your flavor schemes

> **Important:** The `CUSTOM_GROUP_ID` value **must be identical** in both the Runner target and the
> Share Extension target. A mismatch is the most common reason the sharing callback never fires —
> the extension writes shared data to one App Group container while the plugin reads from a different
> one. Double-check `Build Settings → User-Defined → CUSTOM_GROUP_ID` in both targets after any
> rename or flavor change.

##### Make sure the deployment target for Runner.app and the share extension is the same.


#### 5. Add the following code in [ios/Share Extension/Info.plist](./example/ios/Share%20Extension/Info.plist):

```xml
....
    <key>AppGroupId</key>
    <string>$(CUSTOM_GROUP_ID)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
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
            <!-- To share plain text into your app -->
            <key>NSExtensionActivationSupportsPlainText</key>
            <true/>
          
        </dict>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
    </dict>
....
```


[//]: # (#### 5. Add following code to [ios/Runner/Runner.entitlements]&#40;./example/ios/Runner/Runner.entitlements&#41;:)

[//]: # ()
[//]: # ()
[//]: # (```xml)

[//]: # (....)

[//]: # (    <!--TODO:  Add this tag-->)

[//]: # (    <key>com.apple.security.application-groups</key>)

[//]: # (    <array>)

[//]: # (    <string>group.com.techind.flutterSharingIntentExample</string>)

[//]: # (    </array>)

[//]: # (....)

[//]: # (```)

[//]: # ()
[//]: # (Here `group.com.techind.flutterSharingIntentExample` is the App Group ID created in previous step.)

#### 6. Make your `ShareViewController` [ios/Share Extension/ShareViewController.swift](./example/ios/Share%20Extension/ShareViewController.swift) inherit from `FSIShareViewController`:

You no longer need to copy any controller file into your Share Extension. Just
`import flutter_sharing_intent` and inherit from `FSIShareViewController`, which
ships with the plugin:

```swift
// If you get a `no such module 'flutter_sharing_intent'` error,
// go to Build Phases of your Runner target and move
// `Embed Foundation Extension` to the top of `Thin Binary`.

import flutter_sharing_intent

class ShareViewController: FSIShareViewController {

    // Override this method to return false if you don't want to redirect
    // to the host app automatically. Default is true.
    // override func shouldAutoRedirect() -> Bool {
    //     return false
    // }

}
```

#### 7. Add following code in your host app AppDelegate file - [ios/Runner/AppDelegate.swift](./example/ios/Runner/AppDelegate.swift)
> **⚠️ IMPORTANT NOTE**  
> Do **NOT** replace your existing `AppDelegate.swift` file or remove any existing code.  
> You should **add the following snippet** to your current file and merge it with your existing logic.  
> Keep any other URL handling logic you already have (Firebase, uni_links, deep links, etc.).

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

#### 8. UIScene lifecycle (Flutter 3.38+)

The plugin auto-registers as a `FlutterSceneLifeCycleDelegate` — share URLs keep working under UIScene.

If your host app adopts `UIApplicationSceneManifest`:

- Move `GeneratedPluginRegistrant.register(...)` from `application:didFinishLaunchingWithOptions:` into `didInitializeImplicitFlutterEngine` (see [docs.flutter.dev/to/uiscene-migration](https://docs.flutter.dev/to/uiscene-migration)).
- If your router still receives `SharingMedia-<bundle>://...` URLs, filter that scheme in its redirect — payload is already delivered via `getInitialSharing` / `getMediaStream`.

## Full Example

```dart
import 'dart:async';
import 'package:flutter/material.dart';
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
    // For sharing coming from outside the app while the app is in memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> value) {
      setState(() => list = value);
      _handleSharedFiles(value);
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing coming from outside the app while the app is closed
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> value) {
      setState(() => list = value);
      _handleSharedFiles(value);
    });
  }

  // Always check file.type on each individual SharedFile in a loop.
  // Do NOT compare list.map((f) => f.type) to an enum — that always returns false.
  void _handleSharedFiles(List<SharedFile> sharedFiles) {
    for (final file in sharedFiles) {
      switch (file.type) {
        case SharedMediaType.URL:
          print("Shared URL: ${file.value}");
        case SharedMediaType.TEXT:
          print("Shared text: ${file.value}");
        case SharedMediaType.IMAGE:
          print("Shared image path: ${file.value}");
        case SharedMediaType.VIDEO:
          print("Shared video: ${file.value}, thumbnail: ${file.thumbnail}");
        case SharedMediaType.FILE:
          print("Shared file: ${file.value}, mimeType: ${file.mimeType}");
        default:
          print("Shared other: ${file.value}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Sharing data: \n${list?.join("\n\n")}\n'),
          ),
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

> **Tip:** Always check `file.type` on each individual `SharedFile` in a loop.
> Comparing `sharedFiles.map((f) => f.type) == SharedMediaType.URL` compares an
> `Iterable` to an enum value and always returns `false`.

## Troubleshooting

* Error: No such module 'flutter_sharing_intent'
  *  Fix: Go to Build Phases of your Runner target and move `Embed Foundation Extension` to the top of `Thin Binary`.


* Error: App does not build after adding Share Extension?
  * Fix: Check Build Settings of your share extension and remove everything that tries to import Cocoapods from your main project. i.e. remove everything under `Linking/Other Linker Flags` 

* You might need to disable bitcode for the extension target

* Error: Invalid Bundle. The bundle at 'Runner.app/Plugins/Sharing Extension.appex' contains disallowed file 'Frameworks'
    * Fix: https://stackoverflow.com/a/25789145/2061365

* Error (Xcode): Cycle inside Runner; building could produce unreliable results.
  * This build cycle is triggered when the `Embed App Extensions` phase runs after `Thin Binary` in the Runner target's Build Phases. Xcode ends up with a circular dependency between copying the `.appex` bundle and stripping/processing binaries.
  * Fix: In Xcode, open your **Runner** target → **Build Phases** tab. Drag the **Embed Foundation Extensions** (or **Embed App Extensions**) phase so it appears **above** the **Thin Binary** phase. Clean the build folder (`Product → Clean Build Folder`) and rebuild.
  * Reference: [Flutter issue #135739](https://github.com/flutter/flutter/issues/135739)

* Error (Xcode): `'Flutter/Flutter.h' file not found`
  * This usually means `use_frameworks!` is missing from your `ios/Podfile`. The plugin requires dynamic frameworks.
  * Fix: Add `use_frameworks!` inside the `target 'Runner' do` block in your `ios/Podfile` (see the Podfile snippet in the iOS Setup section above), then run `pod install` again.

* iOS: App loads after sharing, but the sharing callback never fires / `getMediaStream()` receives no data
  * The most common cause is an **App Group ID mismatch** between the Runner target and the Share Extension target.  The Share Extension writes to one group container and the plugin reads from a different one, so the data is never delivered.
  * Fix: In Xcode, verify that the `CUSTOM_GROUP_ID` User-Defined build setting is set to **exactly the same string** in both the `Runner` target and the `Share Extension` target (Build Settings → User-Defined → CUSTOM_GROUP_ID).  Also confirm both targets have the same App Group enabled under Signing & Capabilities.
  * Additional check: make sure `AppGroupId` in both `ios/Runner/Info.plist` and `ios/Share Extension/Info.plist` is `$(CUSTOM_GROUP_ID)` (not a hard-coded string that might differ between flavors).

* How do I get the file extension from a shared file?
  * The `SharedFile.mimeType` field contains the MIME type string (e.g. `"image/jpeg"`, `"application/pdf"`).  Derive the extension from it:
  ```dart
  import 'package:mime/mime.dart'; // add mime: ^1.0.0 to pubspec.yaml
  final ext = extensionFromMime(file.mimeType ?? ''); // e.g. "jpeg", "pdf"
  ```
  * Alternatively, use `path` package: `extension(file.value)` returns the extension from the cached file path (e.g. `".jpg"`).  This works for most shared files but may return an empty string for content URIs that were resolved without an extension.