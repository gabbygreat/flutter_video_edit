import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_edit/video_edit_model.dart';

import 'video_edit_method_channel.dart';

abstract class VideoEditPlatform extends PlatformInterface {
  /// Constructs a VideoEditPlatform.
  VideoEditPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoEditPlatform _instance = MethodChannelVideoEdit();

  /// The default instance of [VideoEditPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoEdit].
  static VideoEditPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoEditPlatform] when
  /// they register themselves.
  static set instance(VideoEditPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int?> getBatteryLevel() {
    throw UnimplementedError('getBatteryLevel() has not been implemented.');
  }

  Future<File?> addImageToVideo(List<VideoEditModel> data) {
    throw UnimplementedError('addImageToVideo() has not been implemented.');
  }
}
