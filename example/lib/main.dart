import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_edit/video_edit.dart';
import 'package:video_edit_example/edit_video.dart';
import 'package:video_edit_example/video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
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
  File? videoFile;
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

  void editVideo(File newFile) {
    setState(() {
      videoFile = newFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () async => await _videoEditPlugin.getBatteryLevel(),
          child: const Text(
            'Plugin Video Edit App',
          ),
        ),
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
                      builder: (context) =>
                          VideoEditScreen(file: value, editVideo: editVideo),
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
            onPressed: () {
              if (videoFile != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoApp(file: videoFile!),
                  ),
                );
              }
            },
            child: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
