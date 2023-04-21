import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_edit/video_edit.dart';
import 'package:video_edit/video_edit_model.dart';
import 'package:video_edit_example/draggable_card.dart';
import 'package:video_edit_example/drawing/drawing_canvas.dart';
import 'package:video_edit_example/riverpod/notifier.dart';
import 'package:video_edit_example/riverpod/state_model.dart';
import 'package:video_player/video_player.dart';

import 'drawing/model.dart';
import 'dart:ui' as ui;

enum VideoEditType { none, image, text, emoji, draw }

class VideoEditScreen extends ConsumerStatefulWidget {
  final File file;
  final Function editVideo;
  const VideoEditScreen({
    super.key,
    required this.file,
    required this.editVideo,
  });

  @override
  ConsumerState<VideoEditScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends ConsumerState<VideoEditScreen> {
  late VideoPlayerController _controller;
  VideoEditType videoEditType = VideoEditType.none;
  final _videoEditPlugin = VideoEdit();
  FocusNode focusNode = FocusNode();
  late TextEditingController _textEditingController;
  final videoEditNotifierProvider =
      StateNotifierProvider((ref) => VideoEditNotifier([]));

  late double videoHeight;
  late double videoWidth;

  List<DraggableWidget> widgetList = [];

  //FOR PAINT
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
        videoWidth = _controller.value.size.width;
        videoHeight = _controller.value.size.height;
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
    var decodedImage =
        await decodeImageFromList(File(image.path).readAsBytesSync());

    final test = VideoStateModel(
      imagePath: image.path,
      videoPath: widget.file.path,
      x: decodedImage.width / 2,
      y: decodedImage.height / 2,
      type: FFMPegType.image,
      date: DateTime.now(),
    );
    ref.read(videoEditNotifierProvider.notifier).addToList(test);

    widgetList.add(
      DraggableWidget(
        onMove: (x, y) {
          print(x);
          print(y);
          ref
              .read(videoEditNotifierProvider.notifier)
              .updatePosition(test, x, y);
        },
        child: Image.file(
          File(image.path),
          height: 200,
          width: 200,
        ),
      ),
    );
    setState(() {});
  }

  void addText() {
    focusNode.unfocus();
    if (_textEditingController.text.isNotEmpty) {
      final test = VideoStateModel(
          text: _textEditingController.text,
          videoPath: widget.file.path,
          x: 0,
          y: 0,
          type: FFMPegType.text,
          date: DateTime.now());
      ref.read(videoEditNotifierProvider.notifier).addToList(test);

      widgetList.add(
        DraggableWidget(
          child: Text(
            _textEditingController.text,
            style: const TextStyle(fontSize: 50),
          ),
          onMove: (x, y) {
            ref
                .read(videoEditNotifierProvider.notifier)
                .updatePosition(test, x, y);
          },
        ),
      );

      _textEditingController.clear();
    }
  }

  void addDrawing() {
    videoEditType = VideoEditType.none;
    setState(() {});
  }

  Future<void> saveEdit() async {
    final test = ref.read(videoEditNotifierProvider.notifier).getList().map(
      (e) {
        late VideoEditModel a;
        if (e.type == FFMPegType.image) {
          a = VideoEditModel(
            videoPath: widget.file.path,
            type: VideoEditTypes.image,
            image: ImageModel(
              imagePath: e.imagePath,
              imageX: e.x,
              imageY: e.y,
            ),
          );
        } else if (e.type == FFMPegType.text) {
          a = VideoEditModel(
            videoPath: widget.file.path,
            type: VideoEditTypes.text,
            text: TextModel(
              text: e.text,
              textX: e.x,
              textY: e.y,
            ),
          );
        }
        return a;
      },
    ).toList();
    _videoEditPlugin.addImageToVideo(test).then((value) {
      if (value != null) {
        widget.editVideo(value);
      }
      Navigator.of(context).pop();
    });
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
                                  allSketches.value.clear();
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
            onPressed: () async => await saveEdit(),
            child: const Icon(Icons.save),
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
