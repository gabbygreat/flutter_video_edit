import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_edit/video_edit.dart';
import 'package:video_edit_example/edit_video.dart';
import 'package:video_edit_example/video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _videoEditPlugin = VideoEdit();
  XFile? edittedVideo;

  Future<File> getFile(String assetPath) async {
    ByteData bytes = await rootBundle.load(assetPath); //load sound from assets
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    final tempDir = await getTemporaryDirectory();
    String fileName = assetPath.split('/').last;
    File file = await File('${tempDir.path}/$fileName').create();
    file.writeAsBytesSync(soundbytes);
    return file;
  }

  Future<File?> doNormal() async {
    File videoFile = await getFile('assets/test.mp4');
    return videoFile;
  }

  Future<File?> doImage({File? video}) async {
    File imageFile = await getFile('assets/logo.png');
    late File videoFile;
    if (video != null) {
      videoFile = video;
    } else {
      videoFile = await getFile('assets/test.mp4');
    }
    return await _videoEditPlugin.addImageToVideo({
      "imagePath": imageFile.path,
      "videoPath": videoFile.path,
      "x": 500,
      "y": 100,
    });
  }

  Future<File?> doText({File? video}) async {
    late File videoFile;
    if (video != null) {
      videoFile = video;
    } else {
      videoFile = await getFile('assets/test.mp4');
    }
    final a = await _videoEditPlugin.addTextToVideo({
      "text": 'Vigoplace',
      "videoPath": videoFile.path,
      "x": 500,
      "y": 300,
    });
    return a;
  }

  Future<File?> doShapes({File? video}) async {
    late File videoFile;
    if (video != null) {
      videoFile = video;
    } else {
      videoFile = await getFile('assets/test.mp4');
    }

    const shapeColor = Colors.black;
    String hex = "0x${shapeColor.value.toRadixString(16).substring(2)}";
    final a = await _videoEditPlugin.addShapesToVideo({
      "videoPath": videoFile.path,
      "color": hex,
    });
    return a;
  }

  Future<File?> doAll() async {
    final a = await doShapes();
    final b = await doImage(video: a);
    final c = await doText(video: b);
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Video Edit App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.black26,
              elevation: 0,
              onPressed: () async {
                getFile('assets/test.mp4').then(
                  (value) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoEditScreen(
                        file: value,
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
      floatingActionButton: Wrap(
        // mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: '0',
            onPressed: () => doNormal().then((value) {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoApp(file: value),
                  ),
                );
              }
            }),
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: '1',
            onPressed: () => doImage().then((value) {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoApp(file: value),
                  ),
                );
              }
            }),
            child: const Icon(Icons.image),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: '2',
            onPressed: () => doText().then((value) {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoApp(file: value),
                  ),
                );
              }
            }),
            child: const Icon(Icons.edit),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: '3',
            onPressed: () => doShapes().then((value) {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoApp(file: value),
                  ),
                );
              }
            }),
            child: const Icon(Icons.shape_line),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: '4',
            onPressed: () => doAll().then((value) {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoApp(file: value),
                  ),
                );
              }
            }),
            child: const Icon(Icons.all_out),
          ),
        ],
      ),
    );
  }
}
