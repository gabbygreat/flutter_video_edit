import 'package:flutter_test/flutter_test.dart';
import 'package:video_edit/video_edit.dart';
import 'package:video_edit/video_edit_model.dart';
import 'package:video_edit/video_edit_platform_interface.dart';
import 'package:video_edit/video_edit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:io';

class MockVideoEditPlatform
    with MockPlatformInterfaceMixin
    implements VideoEditPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<int?> getBatteryLevel() => Future.value(1);

  @override
  Future<File?> addImageToVideo(List<VideoEditModel> data) =>
      Future.value(null);
}

void main() {
  final VideoEditPlatform initialPlatform = VideoEditPlatform.instance;

  test('$MethodChannelVideoEdit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVideoEdit>());
  });

  test('getPlatformVersion', () async {
    VideoEdit videoEditPlugin = VideoEdit();
    MockVideoEditPlatform fakePlatform = MockVideoEditPlatform();
    VideoEditPlatform.instance = fakePlatform;

    expect(await videoEditPlugin.getPlatformVersion(), '42');
  });
}
