import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state_model.dart';

extension ListUpdateExtension<E> on List<E> {
  List<E> updateWhere(bool Function(E) condition, E update) {
    final index = indexWhere(condition);
    if (index != -1) {
      this[index] = update;
    }
    return this;
  }
}

class VideoEditNotifier extends StateNotifier<List<VideoStateModel>> {
  VideoEditNotifier(super.state);

  void addToList(VideoStateModel videoStateModel) {
    state = [...state, videoStateModel];
  }

  void updatePosition(VideoStateModel videoStateModel, double x, double y) {
    var test = VideoStateModel(
        imagePath: videoStateModel.imagePath,
        videoPath: videoStateModel.videoPath,
        text: videoStateModel.text,
        date: videoStateModel.date,
        type: videoStateModel.type,
        x: x.toInt(),
        y: y.toInt());
    state = state.updateWhere((p0) => p0.date == videoStateModel.date, test);
  }

  List<VideoStateModel> getList() {
    return state;
  }

  void clearState() {
    state = [];
  }
}
