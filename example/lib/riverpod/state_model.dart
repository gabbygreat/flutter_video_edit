enum FFMPegType { image, text, draw }

class VideoStateModel {
  final String? imagePath;
  final String? text;
  final String videoPath;
  final double x;
  final double y;
  final DateTime date;
  final FFMPegType type;

  VideoStateModel({
    this.imagePath,
    required this.videoPath,
    required this.x,
    this.text,
    required this.y,
    required this.date,
    required this.type,
  });
}
