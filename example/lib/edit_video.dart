import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_edit/video_edit.dart';
import 'package:video_edit_example/draggable_card.dart';
import 'package:video_edit_example/drawing/drawing_canvas.dart';
import 'package:video_player/video_player.dart';

import 'drawing/model.dart';
import 'dart:ui' as ui;

enum VideoEditType { none, image, text, emoji, draw }

class VideoEditScreen extends StatefulWidget {
  final File file;
  const VideoEditScreen({super.key, required this.file});

  @override
  State<VideoEditScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends State<VideoEditScreen> {
  late VideoPlayerController _controller;
  final _videoEditPlugin = VideoEdit();
  VideoEditType videoEditType = VideoEditType.none;
  FocusNode focusNode = FocusNode();
  late TextEditingController _textEditingController;

  List<XFile> imageFiles = [];

  List<DraggableWidget> widgetList = [];

  //FOR PAINT
  List<DraggableWidget> fakeWidgetList = [];

  final selectedColor = ValueNotifier(Colors.black);
  final drawingMode = ValueNotifier(DrawingMode.pencil);
  final filled = ValueNotifier<bool>(false);
  final polygonSides = ValueNotifier<int>(4);
  final backgroundImage = ValueNotifier<ui.Image?>(null);
  ValueNotifier<Sketch?> currentSketch = ValueNotifier(null);
  ValueNotifier<List<Sketch>> allSketches = ValueNotifier([]);
  final canvasGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _controller = VideoPlayerController.file(widget.file)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
      })
      ..play();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          videoEditType = VideoEditType.none;
        });
      }
    });
  }

  Future<void> pickFile() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    imageFiles.add(image);
    widgetList.add(
      DraggableWidget(
        onMove: (x, y) {},
        child: Image.file(
          File(image.path),
          height: 100,
          width: 100,
        ),
      ),
    );
    // videoEditType = VideoEditType.image;
    setState(() {});
  }

  void addText() {
    focusNode.unfocus();
    if (_textEditingController.text.isNotEmpty) {
      widgetList.add(
        DraggableWidget(
          child: Text(
            _textEditingController.text,
            style: const TextStyle(fontSize: 50),
          ),
          onMove: (x, y) {},
        ),
      );
      _textEditingController.clear();
    }
  }

  void addDrawing() {
    videoEditType = VideoEditType.none;
    setState(() {});
  }

  Future<void> shareEdit() async {
    late File? file;
    for (var i in imageFiles) {
      file = await _videoEditPlugin.addImageToVideo({
        "imagePath": i.path,
        "videoPath": widget.file.path,
        "x": 500,
        "y": 100,
      });
    }
    Share.shareXFiles([XFile(file!.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () async {
          // videoEditType = VideoEditType.none;
          if (videoEditType != VideoEditType.draw) {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
            } else {
              if (_controller.value.isPlaying) {
                await _controller.pause();
              } else {
                await _controller.play();
              }
              setState(() {});
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Stack(
              children: [
                if (_controller.value.isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ...widgetList,
                if (videoEditType != VideoEditType.draw &&
                    !_controller.value.isPlaying)
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black45,
                      child: Center(
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (videoEditType == VideoEditType.text)
                  Center(
                    child: TextField(
                      controller: _textEditingController,
                      focusNode: focusNode,
                      textAlign: TextAlign.center,
                      onSubmitted: (value) => addText(),
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        fontSize: 50,
                      ),
                      maxLines: null,
                      minLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                if (videoEditType == VideoEditType.draw)
                  DrawingAppCanvas(
                    drawingMode: drawingMode,
                    selectedColor: selectedColor,
                    currentSketch: currentSketch,
                    allSketches: allSketches,
                    canvasGlobalKey: canvasGlobalKey,
                    filled: filled,
                    polygonSides: polygonSides,
                    backgroundImage: backgroundImage,
                    widgetList: widgetList,
                  ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (videoEditType == VideoEditType.none)
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              )
                            else if (videoEditType == VideoEditType.draw)
                              ElevatedButton(
                                onPressed: addDrawing,
                                child: const Text('Done'),
                              )
                            else if (videoEditType == VideoEditType.text)
                              ElevatedButton(
                                onPressed: addText,
                                child: const Text('Done'),
                              ),
                            const Spacer(),
                            IconButton(
                              onPressed: pickFile,
                              icon: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                focusNode.requestFocus();
                                videoEditType = VideoEditType.text;
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.text_fields_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (videoEditType == VideoEditType.draw) {
                                  videoEditType = VideoEditType.none;
                                } else {
                                  videoEditType = VideoEditType.draw;
                                  fakeWidgetList.clear();
                                }
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async => await shareEdit(),
            child: const Icon(Icons.share),
          ),
          bottomSheet: videoEditType == VideoEditType.draw
              ? Container(
                  color: Colors.black87,
                  height: kBottomNavigationBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          drawingMode.value = DrawingMode.pencil;
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          drawingMode.value = DrawingMode.line;
                        },
                        icon: const Icon(
                          Icons.horizontal_rule,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          drawingMode.value = DrawingMode.polygon;
                        },
                        icon: const Icon(
                          Icons.rectangle_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          drawingMode.value = DrawingMode.circle;
                        },
                        icon: const Icon(
                          Icons.circle_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _textEditingController.dispose();
    selectedColor.dispose();
    drawingMode.dispose();
    filled.dispose();
    polygonSides.dispose();
    backgroundImage.dispose();
    currentSketch.dispose();
    allSketches.dispose();
  }
}
