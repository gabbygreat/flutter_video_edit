import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_edit/video_edit_method_channel.dart';

void main() {
  MethodChannelVideoEdit platform = MethodChannelVideoEdit();
  const MethodChannel channel = MethodChannel('video_edit');

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
