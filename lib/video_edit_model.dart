import 'dart:io';

enum VideoEditTypes { image, text }

class ImageModel {
  final String? imagePath;
  final double? imageX;
  final double? imageY;

  ImageModel({
    required this.imagePath,
    required this.imageX,
    required this.imageY,
  });
}

class TextModel {
  final String? text;
  final double? textX;
  final double? textY;

  TextModel({
    required this.text,
    required this.textX,
    required this.textY,
  });
}

class VideoEditModel {
  final String videoPath;
  final ImageModel? image;
  final TextModel? text;
  final VideoEditTypes type;

  VideoEditModel({
    this.image,
    this.text,
    required this.videoPath,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    if (type == VideoEditTypes.image) {
      assert(image?.imagePath != null, "imagePath must not be null");
      assert(File(image!.imagePath!).existsSync(), "Image file must exist");
      assert(image?.imageX != null,
          "Since imagePath is not null, X-position must not be null");
      assert(image?.imageY != null,
          "Since imagePath is not null, Y-position must not be null");
    } else if (type == VideoEditTypes.text) {
      assert(text?.text != null, "Text cannot be null");
      assert(text!.text!.isNotEmpty, "text cannot be empty");
      assert(text?.textX != null,
          "Since text is not null, X-position must not be null");
      assert(text?.textY != null,
          "Since imagePath is not null, Y-position must not be null");
    }
    assert(image != null || text != null,
        " One of two image or text must be null");
    assert(image == null || text == null,
        " One of two image or text must be null");
    return {
      "videoPath": videoPath,
      "text": text?.text,
      "textX": text?.textX,
      "textY": text?.textY,
      "imagePath": image?.imagePath,
      "imageX": image?.imageX,
      "imageY": image?.imageY,
    };
  }
}
