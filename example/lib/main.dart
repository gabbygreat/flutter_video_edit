import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_edit/video_edit.dart';
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

  Future<File?> doImage() async {
    File imageFile = await getFile('assets/logo.png');
    File videoFile = await getFile('assets/test.mp4');
    return await _videoEditPlugin.addImageToVideo({
      "imagePath": imageFile.path,
      "videoPath": videoFile.path,
      "x": 500,
      "y": 100,
    });
  }

  Future<File?> doText() async {
    File videoFile = await getFile('assets/test.mp4');
    final a = await _videoEditPlugin.addTextToVideo({
      "text": 'Vigoplace',
      "videoPath": videoFile.path,
      "x": 500,
      "y": 100,
    });
    return a;
  }

  Future<File?> doShapes() async {
    File videoFile = await getFile('assets/test.mp4');
    final a = await _videoEditPlugin.addShapesToVideo({
      "videoPath": videoFile.path,
    });
    return a;
  }

  Future<File?> doAll() async {
    File videoFile = await getFile('assets/test.mp4');
    File imageFile = await getFile('assets/logo.png');

    final a = await _videoEditPlugin.addShapesToVideo({
      "videoPath": videoFile.path,
    });
    final b = await _videoEditPlugin.addImageToVideo({
      "imagePath": imageFile.path,
      "videoPath": a?.path,
      "x": 500,
      "y": 100,
    });
    final c = await _videoEditPlugin.addTextToVideo({
      "text": 'Vigoplace',
      "videoPath": b?.path,
      "x": 100,
      "y": 100,
    });
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Video Edit App'),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
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
