import 'dart:io';

import 'video_edit_model.dart';
import 'video_edit_platform_interface.dart';

class VideoEdit {
  Future<String?> getPlatformVersion() {
    return VideoEditPlatform.instance.getPlatformVersion();
  }

  Future<int?> getBatteryLevel() {
    return VideoEditPlatform.instance.getBatteryLevel();
  }

  Future<File?> addImageToVideo(List<VideoEditModel> data) {
    return VideoEditPlatform.instance.addImageToVideo(data);
  }
  
}
