import 'dart:async';
import 'dart:convert';

import 'package:flutter_sharing_intent/model/sharing_file.dart';

import 'flutter_sharing_intent_platform_interface.dart';
import 'package:flutter/services.dart';

class FlutterSharingIntent {
  static FlutterSharingIntent instance = FlutterSharingIntent._();
  factory FlutterSharingIntent() => instance;
  late EventChannel _eChannelMedia;
  Stream<List<SharedFile>>? _streamMedia;

  FlutterSharingIntent._() {
    _eChannelMedia =
        const EventChannel("flutter_sharing_intent/events-sharing");
  }

  Future<String?> getPlatformVersion() {
    return FlutterSharingIntentPlatform.instance.getPlatformVersion();
  }

  /// Returns a [Future], which completes to one of the following:
  /// NOTE. The returned media on iOS (iOS ONLY) is already copied to a temp folder.
  /// So, you need to delete the file after you finish using it
  Future<List<SharedFile>> getInitialSharing() {
    return FlutterSharingIntentPlatform.instance.getInitialSharing();
  }

  /// Call this method if you already consumed the callback
  /// and don't want the same callback again
  void reset() {
    return FlutterSharingIntentPlatform.instance.reset();
  }

  /// Sets up a broadcast stream for receiving incoming media share change events.
  ///
  /// Returns a broadcast [Stream] which emits events to listeners as follows:
  /// Errors occurring during stream activation or deactivation are reported
  /// through the `FlutterError` facility. Stream activation happens only when
  /// stream listener count changes from 0 to 1. Stream deactivation happens
  /// only when stream listener count changes from 1 to 0.
  ///
  /// If the app was started by a link intent or user activity the stream will
  /// not emit that initial one - query either the `getInitialMedia` instead.
  Stream<List<SharedFile>> getMediaStream() {
    if (_streamMedia == null) {
      final stream =
          _eChannelMedia.receiveBroadcastStream("sharing").cast<String?>();
      _streamMedia = stream.transform<List<SharedFile>>(
        StreamTransformer<String?, List<SharedFile>>.fromHandlers(
          handleData: (String? data, EventSink<List<SharedFile>> sink) {
            if (data == null) {
              sink.add([]);
            } else {
              final encoded = jsonDecode(data);
              sink.add(encoded
                  .map<SharedFile>((file) => SharedFile.fromJson(file))
                  .toList());
            }
          },
        ),
      );
    }
    return _streamMedia!;
  }
}
