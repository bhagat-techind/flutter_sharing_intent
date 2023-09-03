# flutter_sharing_intent

A flutter plugin that allow flutter apps to receive photos, videos, text, urls or any other file types from another app.

## Features

- It's allow to share image, text, video ,urls and file from other app to flutter app.
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

### Android

android/app/src/main/manifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="{YOUR_PACKAGE_NAME}">
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

### IOS

#### 1. Add the following

ios/Runner/info.plist

```xml
...
<key>AppGroupId</key>
<!--HERE set your group Id-->
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

#### 2. Create Share Extension

- Using xcode, go to File/New/Target and Choose "Share Extension"
- Give it a name i.e. "Share Extension"

##### Make sure the deployment target for Runner.app and the share extension is the same.

##### Add the following code:

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

ios/Share Extension/ShareViewController.swift

- Look at `loadIds()` for configure and details
- hostAppBundleIdentifier will be your host app bundle identifier. For example in my case `com.techind.flutterSharingIntentExample`

```swift
import UIKit
import Social
import MobileCoreServices
import Photos
import UniformTypeIdentifiers
import AVFoundation
import ImageIO

@objc(ShareViewController)
class ShareViewController: UIViewController {
        // TODO: IMPORTANT: This should be your host app bundle identifier
        var hostAppBundleIdentifier = "com.techind.flutterSharingIntentExample"
        let sharedKey = "SharingKey"
        var appGroupId = ""
        var sharedMedia: [SharingFile] = []
        var sharedText: [String] = []

        let imageContentType = UTType.image.identifier;
        let videoContentType = UTType.movie.identifier;
        let textContentType = UTType.text.identifier;
        let urlContentType = UTType.url.identifier;
        let fileURLType = UTType.fileURL.identifier;

    override func viewDidLoad() {
        super.viewDidLoad()
        // load group and app id from build info
        loadIds();

    }

    private func loadIds() {

        // loading Share extension App Id
        let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!;


        // convert ShareExtension id to host app id
        // By default it is remove last part of id after last point
        // For example: com.test.ShareExtension -> com.test
        let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".");
        hostAppBundleIdentifier = String(shareExtensionAppBundleIdentifier[..<lastIndexOfPoint!]);

        // loading custom AppGroupId from Build Settings or use group.<hostAppBundleIdentifier>
        appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(hostAppBundleIdentifier)";
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        // This will called after the user selects app from sharing app list.
        handleImageAttachment()

       }

    func handleImageAttachment(){
        if let content = self.extensionContext?.inputItems.first as? NSExtensionItem {
               if let contents = content.attachments {
                   for (index, attachment) in (contents).enumerated() {
                       if attachment.isImage {
                           handleImages(content: content, attachment: attachment, index: index)
                       } else if attachment.isMovie {
                           handleVideos(content: content, attachment: attachment, index: index)
                       }
                       else if attachment.isFile {
                          handleFiles(content: content, attachment: attachment, index: index)
                      }
                       else if attachment.isURL {
                           handleUrl(content: content, attachment: attachment, index: index)
                       }
                       else if attachment.isText {
                           handleText(content: content, attachment: attachment, index: index)
                       } else {
                           print(" \(attachment) File type is not supported by flutter shaing plugin.")
                       }

                   }
               }
           }

    }


    private func handleText (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: textContentType, options: nil) { [weak self] data, error in

            if error == nil, let item = data as? String, let this = self {

                this.sharedText.append(item)

                // If this is the last item, save imagesData in userDefaults and redirect to host app
                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: this.appGroupId)
                    userDefaults?.set(this.sharedText, forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .text)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }

    private func handleUrl (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
          attachment.loadItem(forTypeIdentifier: urlContentType, options: nil) { [weak self] data, error in

              if error == nil, let item = data as? URL, let this = self {

                  this.sharedText.append(item.absoluteString)

                  // If this is the last item, save imagesData in userDefaults and redirect to host app
                  if index == (content.attachments?.count)! - 1 {
                      let userDefaults = UserDefaults(suiteName: this.appGroupId)
                      userDefaults?.set(this.sharedText, forKey: this.sharedKey)
                      userDefaults?.synchronize()
                      this.redirectToHostApp(type: .url)
                  }

              } else {
                  self?.dismissWithError()
              }
          }
      }

    private func handleImages (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {

        attachment.loadItem(forTypeIdentifier: imageContentType, options: nil) { [weak self] data, error in
             if error == nil, let url = data as? URL, let this = self {
                 // Always copy
                 let fileName = this.getFileName(from: url, type: .image)
                 let newPath = FileManager.default
                     .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                     .appendingPathComponent(fileName)
                 let copied = this.copyFile(at: url, to: newPath)
                 if(copied) {
                     this.sharedMedia.append(SharingFile(value: newPath.absoluteString, thumbnail: nil, duration: nil, type: .image))
                 }

                 // If this is the last item, save imagesData in userDefaults and redirect to host app
                 if index == (content.attachments?.count)! - 1 {
                     let userDefaults = UserDefaults(suiteName: this.appGroupId)
                     userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.sharedKey)
                     userDefaults?.synchronize()
                     this.redirectToHostApp(type: .media)
                 }

             } else {
                  self?.dismissWithError()
             }
         }
     }

    private func handleVideos (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
          attachment.loadItem(forTypeIdentifier: videoContentType, options: nil) { [weak self] data, error in

              if error == nil, let url = data as? URL, let this = self {

                  // Always copy
                  let fileName = this.getFileName(from: url, type: .video)
                  let newPath = FileManager.default
                      .containerURL(forSecurityApplicationGroupIdentifier:this.appGroupId)!
                      .appendingPathComponent(fileName)
                  let copied = this.copyFile(at: url, to: newPath)
                  if(copied) {
                      guard let sharedFile = this.getSharedMediaFile(forVideo: newPath) else {
                          return
                      }
                      this.sharedMedia.append(sharedFile)
                  }

                  // If this is the last item, save imagesData in userDefaults and redirect to host app
                  if index == (content.attachments?.count)! - 1 {
                      let userDefaults = UserDefaults(suiteName: this.appGroupId)
                      userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.sharedKey)
                      userDefaults?.synchronize()
                      this.redirectToHostApp(type: .media)
                  }

              } else {
                   self?.dismissWithError()
              }
          }
      }

    private func handleFiles (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
          attachment.loadItem(forTypeIdentifier: fileURLType, options: nil) { [weak self] data, error in

              if error == nil, let url = data as? URL, let this = self {

                  // Always copy
                  let fileName = this.getFileName(from :url, type: .file)
                  let newPath = FileManager.default
                      .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                      .appendingPathComponent(fileName)
                  let copied = this.copyFile(at: url, to: newPath)
                  if (copied) {
                      this.sharedMedia.append(SharingFile(value: newPath.absoluteString, thumbnail: nil, duration: nil, type: .file))
                  }

                  if index == (content.attachments?.count)! - 1 {
                      let userDefaults = UserDefaults(suiteName:this.appGroupId)
                      userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.sharedKey)
                      userDefaults?.synchronize()
                      this.redirectToHostApp(type: .file)
                  }

              } else {
                  self?.dismissWithError()
              }
          }
      }

    private func dismissWithError() {
            print("[ERROR] Error loading data!")
            let alert = UIAlertController(title: "Error", message: "Error loading data", preferredStyle: .alert)

            let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                self.dismiss(animated: true, completion: nil)
            }

            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }

        private func redirectToHostApp(type: RedirectType) {
            // load group and app id from build info
            loadIds();
            let url = URL(string: "SharingMedia-\(hostAppBundleIdentifier)://dataUrl=\(sharedKey)#\(type)")
            var responder = self as UIResponder?
            let selectorOpenURL = sel_registerName("openURL:")

            while (responder != nil) {
                if (responder?.responds(to: selectorOpenURL))! {
                    let _ = responder?.perform(selectorOpenURL, with: url)
                }
                responder = responder!.next
            }
            extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }

        enum RedirectType {
            case media
            case text
            case file
            case url
        }

        func getExtension(from url: URL, type: SharingFileType) -> String {
            let parts = url.lastPathComponent.components(separatedBy: ".")
            var ex: String? = nil
            if (parts.count > 1) {
                ex = parts.last
            }

            if (ex == nil) {
                switch type {
                    case .image:
                        ex = "PNG"
                    case .video:
                        ex = "MP4"
                    case .file:
                        ex = "TXT"
                    case .text:
                        ex = "TXT"
                    case .url:
                        ex = "TXT"
                    }
            }
            return ex ?? "Unknown"
        }

        func getFileName(from url: URL, type: SharingFileType) -> String {
            var name = url.lastPathComponent

            if (name.isEmpty) {
                name = UUID().uuidString + "." + getExtension(from: url, type: type)
            }

            return name
        }

        func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
            do {
                if FileManager.default.fileExists(atPath: dstURL.path) {
                    try FileManager.default.removeItem(at: dstURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            } catch (let error) {
                print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
                return false
            }
            return true
        }

    private func getSharedMediaFile(forVideo: URL)  -> SharingFile? {
            let asset = AVAsset(url: forVideo)
            let duration = (CMTimeGetSeconds(asset.duration) * 1000).rounded()
            let thumbnailPath = getThumbnailPath(for: forVideo)

            if FileManager.default.fileExists(atPath: thumbnailPath.path) {
                return SharingFile(value: forVideo.absoluteString, thumbnail: thumbnailPath.absoluteString, duration: duration, type: .video)
            }

            var saved = false
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            //        let scale = UIScreen.main.scale
            assetImgGenerate.maximumSize =  CGSize(width: 360, height: 360)
            do {
                let img = try assetImgGenerate.copyCGImage(at: CMTimeMakeWithSeconds(600, preferredTimescale: Int32(1.0)), actualTime: nil)
                try UIImage.pngData(UIImage(cgImage: img))()?.write(to: thumbnailPath)
                saved = true
            } catch {
                saved = false
            }

            return saved ? SharingFile(value: forVideo.absoluteString, thumbnail: thumbnailPath.absoluteString, duration: duration, type: .video) : nil

        }

        private func getThumbnailPath(for url: URL) -> URL {
            let fileName = Data(url.lastPathComponent.utf8).base64EncodedString().replacingOccurrences(of: "==", with: "")
            let path = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier:appGroupId)!
                .appendingPathComponent("\(fileName).jpg")
            return path
        }

        func toData(data: [SharingFile]) -> Data {
            let encodedData = try? JSONEncoder().encode(data)
            return encodedData!
        }
    }

    extension Array {
        subscript (safe index: UInt) -> Element? {
            return Int(index) < count ? self[Int(index)] : nil
        }

    }

// MARK: - Attachment Types
extension NSItemProvider {
    var isImage: Bool {
        return hasItemConformingToTypeIdentifier(UTType.image.identifier)
    }

    var isMovie: Bool {
        return hasItemConformingToTypeIdentifier(UTType.movie.identifier)
    }

    var isText: Bool {
        return hasItemConformingToTypeIdentifier(UTType.text.identifier)
    }

    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(UTType.url.identifier)
    }
    var isFile: Bool {
        return hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
    }
}
```

Add SharingFile.swift in ios/Share Extension

```swift
import Foundation

class SharingFile: Codable {
    var value: String;
    var thumbnail: String?; // video thumbnail
    var duration: Double?; // video duration in milliseconds
    var type: SharingFileType;


    init(value: String, thumbnail: String?, duration: Double?, type: SharingFileType) {
        self.value = value
        self.thumbnail = thumbnail
        self.duration = duration
        self.type = type
    }

    // toString method to print out SharingFile details in the console
    func toString() {
        print("[SharingFile] \n\tvalue: \(self.value)\n\tthumbnail: \(self.thumbnail ?? "--" )\n\tduration: \(self.duration ?? 0)\n\ttype: \(self.type)")
    }

    func toData(data: [SharingFile]) -> Data {
        let encodedData = try? JSONEncoder().encode(data)
        return encodedData!
    }
}
```

Add SharingFileType.swift in ios/Share Extension

```swift

enum SharingFileType: Int, Codable {
    case text
    case url
    case image
    case video
    case file
}

```

#### 3. Add Runner and Share Extension in the same group

- Go to the Capabilities tab and switch on the App Groups switch for both targets.
- Add a new group and name it as you want. For example `group.YOUR_HOST_APP_BUNDLE_IDENTIFIER` in my case `group.com.techind.flutterSharingIntentExample`

#### 4. Add following code in your host app AppDelegate file

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
