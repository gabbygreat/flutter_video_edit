import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_edit/video_edit_model.dart';

import 'video_edit_platform_interface.dart';

/// An implementation of [VideoEditPlatform] that uses method channels.
class MethodChannelVideoEdit extends VideoEditPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('video_edit');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int?> getBatteryLevel() async {
    final level = await methodChannel.invokeMethod<int>('getBatteryLevel');
    return level;
  }

  @override
  Future<File?> addImageToVideo(List<VideoEditModel> data) async {
    File? file;
    for (var i in data) {
      if (file == null) {
        final a = await methodChannel.invokeMethod<String?>(
            'addImageToVideo', i.toJson());
        if (a == null) return null;
        file = File(a);
      } else {
        final a = await methodChannel.invokeMethod<String?>('addImageToVideo', {
          "videoPath": file.path,
          "text": i.text?.text,
          "textX": i.text?.textX,
          "textY": i.text?.textY,
          "imagePath": i.image?.imagePath,
          "imageX": i.image?.imageX,
          "imageY": i.image?.imageY,
        });
        if (a == null) return null;
        file = File(a);
      }
    }
    return file;
  }
}
