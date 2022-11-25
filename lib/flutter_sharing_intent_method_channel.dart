import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import 'flutter_sharing_intent_platform_interface.dart';

/// An implementation of [FlutterSharingIntentPlatform] that uses method channels.
class MethodChannelFlutterSharingIntent extends FlutterSharingIntentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sharing_intent');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void reset() {
    methodChannel.invokeMethod('reset');
  }

  @override
  Future<List<SharedFile>> getInitialSharing() async {
    final json = await methodChannel.invokeMethod('getInitialSharing');
    if (json == null) return [];
    final encoded = jsonDecode(json);
    return encoded
        .map<SharedFile>((file) => SharedFile.fromJson(file))
        .toList();
  }
}
