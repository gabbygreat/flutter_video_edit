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

  Future<File?> addImageToVideo(VideoEditImage data) {
    return VideoEditPlatform.instance.addImageToVideo(data.toMap());
  }

  Future<File?> addTextToVideo(VideoEditText data) {
    return VideoEditPlatform.instance.addTextToVideo(data.toMap());
  }

  Future<File?> addShapesToVideo(Map<String, dynamic> data) {
    return VideoEditPlatform.instance.addShapesToVideo(data);
  } 
  Future<String?> addImageToVideo2(Map<String, dynamic> data) {
    return VideoEditPlatform.instance.addImageToVideo2(data);
  }
  
}
