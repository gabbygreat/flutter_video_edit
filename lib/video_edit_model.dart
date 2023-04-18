class VideoEditText {
  final String text;
  final String videoPath;
  final int x;
  final int y;

  VideoEditText({
    required this.text,
    required this.videoPath,
    required this.x,
    required this.y,
  });

  static VideoEditText fromJson(Map<String, dynamic> data) {
    return VideoEditText(
      text: data['text'],
      videoPath: data['videoPath'],
      x: data['x'] as int,
      y: data['y'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "videoPath": videoPath,
      "x": x,
      "y": y,
    };
  }
}

class VideoEditImage {
  final String imagePath;
  final String videoPath;
  final int x;
  final int y;

  final String text;

  VideoEditImage(
      {required this.imagePath,
      required this.videoPath,
      required this.x,
      required this.y,
      this.text = "Gabriel"});

  Map<String, dynamic> toMap() {
    return {
      "imagePath": imagePath,
      "videoPath": videoPath,
      "x": x,
      "y": y,
      "text": text,
    };
  }

  static VideoEditImage fromJson(Map<String, dynamic> data) {
    return VideoEditImage(
      imagePath: data['imagePath'],
      videoPath: data['videoPath'],
      x: data['x'] as int,
      text: data['text'] ?? "Gabriel",
      y: data['y'] as int,
    );
  }
}
