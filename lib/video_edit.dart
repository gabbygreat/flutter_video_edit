import 'dart:io';

import 'video_edit_platform_interface.dart';

class VideoEdit {
  Future<String?> getPlatformVersion() {
    return VideoEditPlatform.instance.getPlatformVersion();
  }

  Future<int?> getBatteryLevel() {
    return VideoEditPlatform.instance.getBatteryLevel();
  }

  Future<File?> addImageToVideo(Map<String, dynamic> data) {
    return VideoEditPlatform.instance.addImageToVideo(data);
  }

  Future<File?> addTextToVideo(Map<String, dynamic> data) {
    return VideoEditPlatform.instance.addTextToVideo(data);
  }

  Future<File?> addShapesToVideo(Map<String, dynamic> data) {
    return VideoEditPlatform.instance.addShapesToVideo(data);
  }
}
