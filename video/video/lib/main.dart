import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

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

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _controller;
  Timer? _timer;
  int sec = 20;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
        'https://joy1.videvo.net/videvo_files/video/free/video0455/large_watermarked/_import_609113a1be0e89.39394997_preview.mp4');
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((value) => setState(() {}));
    _controller.play();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changeMenuOpacity({bool repeat = false}) {
    if (repeat == true) {
      sec = 5;
    } else {
      if (sec > 0) {
        sec -= 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_controller.value.isPlaying) {
    //   changeMenuOpacity();
    // } else {
    //   sec = 5;
    // }
    double showMenu = sec == 0 ? 0 : 1;
    bool check = _timer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        height: 200,
        child: Stack(
          children: [
            InkWell(
              child: VideoPlayer(_controller),
              onTap: () {
                _timer ??= Timer.periodic(
                  const Duration(seconds: 1),
                  (timer) {
                    changeMenuOpacity();
                    print(sec);
                    if (sec == 0) {
                      timer.cancel();
                      _timer = null;
                    }
                  },
                );
                changeMenuOpacity(repeat: true);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 20,
                child: Slider(
                  min: 0,
                  max: _controller.value.duration.inSeconds.toDouble(),
                  value: _controller.value.position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    _controller.seekTo(
                      Duration(seconds: value.toInt()),
                    );
                  },
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: showMenu,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.rotate_left_outlined),
                          onPressed: () async {
                            Duration currentPosition = Duration.zero;
                            await _controller.position.then(
                              (value) => currentPosition = value!,
                            );
                            check
                                ? _controller.seekTo(
                                    Duration(
                                        seconds: currentPosition.inSeconds - 2),
                                  )
                                : null;
                          },
                        ),
                        _controller.value.isPlaying
                            ? IconButton(
                                icon: const Icon(Icons.stop),
                                onPressed: () {
                                  _controller.pause();
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  _controller.play();
                                },
                              ),
                        IconButton(
                          icon: const Icon(Icons.rotate_right_outlined),
                          onPressed: () async {
                            Duration currentPosition = Duration.zero;
                            await _controller.position
                                .then((value) => currentPosition = value!);
                            check
                                ? _controller.seekTo(
                                    Duration(
                                        seconds: currentPosition.inSeconds + 2),
                                  )
                                : null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
