import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent_method_channel.dart';

void main() {
  MethodChannelFlutterSharingIntent platform = MethodChannelFlutterSharingIntent();
  const MethodChannel channel = MethodChannel('flutter_sharing_intent');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
