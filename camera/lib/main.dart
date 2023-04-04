import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  CameraController? controller;
  XFile? lastimage;

  List<XFile> pictures = [];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    unawaited(initCamera());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    controller = CameraController(cameras[0], ResolutionPreset.max);

    await controller!.initialize();

    setState(() {});
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      controller!.dispose();
    }

    final CameraController cameraController = CameraController(
        cameraDescription, ResolutionPreset.max,
        enableAudio: true, imageFormatGroup: ImageFormatGroup.jpeg);

    controller = cameraController;

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget cameraView = Stack(
      children: [
        controller?.value.isInitialized == true
            ? Center(
                child: CameraPreview(controller!),
              )
            : SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
        if (lastimage != null)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 120,
              height: 240,
              child: Image.file(
                File(lastimage!.path),
                fit: BoxFit.cover,
              ),
            ),
          )
      ],
    );

    Widget galeryView = GridView(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
      children: [
        ...pictures.map((e) => Image.file(
              File(e.path),
              fit: BoxFit.cover,
            ))
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AnimatedCrossFade(
        firstChild: cameraView,
        secondChild: galeryView,
        duration: const Duration(milliseconds: 500),
        crossFadeState: _selectedIndex == 0
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Камера'),
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_in_picture), label: 'Галерея')
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          lastimage = await controller?.takePicture();
          pictures.add(lastimage!);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
