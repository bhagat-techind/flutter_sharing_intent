//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Bhagat on 25/11/22.
//

import UIKit
import Social
import MobileCoreServices
import Photos


class ShareViewController: SLComposeServiceViewController {
//    // TODO: IMPORTANT: This should be your host app bundle identifier
        let hostAppBundleIdentifier = "com.techind.flutterSharingIntentExample"
        let sharedKey = "SharingKey"
        var sharedMedia: [SharingFile] = []
        var sharedText: [String] = []
        let imageContentType = kUTTypeImage as String
        let videoContentType = kUTTypeMovie as String
        let textContentType = kUTTypeText as String
        let urlContentType = kUTTypeURL as String
        let fileURLType = kUTTypeFileURL as String;
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
        print("[viewDidAppear] \(String(describing: index))")
           // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
           if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
               if let contents = content.attachments {
                   for (index, attachment) in (contents).enumerated() {
                       print("[viewDidAppear] \(String(describing: index))")
                       if attachment.hasItemConformingToTypeIdentifier(imageContentType) {
                           handleImages(content: content, attachment: attachment, index: index)
                       } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                           handleText(content: content, attachment: attachment, index: index)
                       } else if attachment.hasItemConformingToTypeIdentifier(fileURLType) {
                           handleFiles(content: content, attachment: attachment, index: index)
                       } else if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                           handleUrl(content: content, attachment: attachment, index: index)
                       } else if attachment.hasItemConformingToTypeIdentifier(videoContentType) {
                           handleVideos(content: content, attachment: attachment, index: index)
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
                    let userDefaults = UserDefaults(suiteName: "group.\(this.hostAppBundleIdentifier)")
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
                      let userDefaults = UserDefaults(suiteName: "group.\(this.hostAppBundleIdentifier)")
                      userDefaults?.set(this.sharedText, forKey: this.sharedKey)
                      userDefaults?.synchronize()
                      this.redirectToHostApp(type: .text)
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
                     .containerURL(forSecurityApplicationGroupIdentifier: "group.\(this.hostAppBundleIdentifier)")!
                     .appendingPathComponent(fileName)
                 let copied = this.copyFile(at: url, to: newPath)
                 if(copied) {
                     this.sharedMedia.append(SharingFile(value: newPath.absoluteString, thumbnail: nil, duration: nil, type: .image))
                 }

                 // If this is the last item, save imagesData in userDefaults and redirect to host app
                 if index == (content.attachments?.count)! - 1 {
                     let userDefaults = UserDefaults(suiteName: "group.\(this.hostAppBundleIdentifier)")
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
                      .containerURL(forSecurityApplicationGroupIdentifier: "group.\(this.hostAppBundleIdentifier)")!
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
                      let userDefaults = UserDefaults(suiteName: "group.\(this.hostAppBundleIdentifier)")
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
                      .containerURL(forSecurityApplicationGroupIdentifier: "group.\(this.hostAppBundleIdentifier)")!
                      .appendingPathComponent(fileName)
                  let copied = this.copyFile(at: url, to: newPath)
                  if (copied) {
                      this.sharedMedia.append(SharingFile(value: newPath.absoluteString, thumbnail: nil, duration: nil, type: .file))
                  }

                  if index == (content.attachments?.count)! - 1 {
                      let userDefaults = UserDefaults(suiteName: "group.\(this.hostAppBundleIdentifier)")
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
            let url = URL(string: "SharingMedia://dataUrl=\(sharedKey)#\(type)")
            print("[redirectToHostApp] \(String(describing: url))")
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

        private func getSharedMediaFile(forVideo: URL) -> SharingFile? {
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
                .containerURL(forSecurityApplicationGroupIdentifier: "group.\(hostAppBundleIdentifier)")!
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
