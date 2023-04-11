import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_edit/video_edit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _batteryLevel = 0;
  final _videoEditPlugin = VideoEdit();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    int batteryLevel;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _videoEditPlugin.getPlatformVersion() ??
          'Unknown platform version';
      batteryLevel = await _videoEditPlugin.getBatteryLevel() ?? -1;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      batteryLevel = -1;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _batteryLevel = batteryLevel;
    });
  }

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

  Future<void> doImage() async {
    print('Hello');
    File imageFile = await getFile('assets/tap.png');
    File videoFile = await getFile('assets/test.mp4');

    final a = await _videoEditPlugin.addImageToVideo({
      "imagePath": imageFile.path,
      "videoPath": videoFile.path,
      "x": 100,
      "y": 100
    });
    if (a != null) {
      debugPrint('Here it is ${a.path}');
    }
    print('above $a');
    debugPrint('object');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await doImage(),
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Battery is at: $_batteryLevel%\n'),
            ],
          ),
        ),
      ),
    );
  }
}
