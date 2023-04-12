import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
  Future<File?> addImageToVideo(Map<String, dynamic> data) async {
    final level =
        await methodChannel.invokeMethod<String?>('addImageToVideo', data);

    if (level == null) return null;
    return File(level);
  }

  @override
  Future<File?> addTextToVideo(Map<String, dynamic> data) async {
    final level =
        await methodChannel.invokeMethod<String?>('addTextToVideo', data);

    if (level == null) return null;
    return File(level);
  }

  @override
  Future<File?> addShapesToVideo(Map<String, dynamic> data) async {
    final level =
        await methodChannel.invokeMethod<String?>('addShapesToVideo', data);

    if (level == null) return null;
    return File(level);
  }
}
