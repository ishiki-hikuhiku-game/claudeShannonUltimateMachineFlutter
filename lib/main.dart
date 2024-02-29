import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shannons_ultimate_machine/helpers/device.helper.dart';
import 'package:shannons_ultimate_machine/helpers/rank.helper.dart';
import 'package:shannons_ultimate_machine/helpers/time.helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'シャノンの究極のマシン',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'シャノンの究極のマシン'),
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
  double _pointerX = 0.0;
  double _pointerY = 0.0;
  final _handPointerWidth = 60.0;
  double _velocity = 0.0;
  bool _inited = false;
  bool _move = false;
  final _destinationKey = GlobalKey(debugLabel: "destination");
  void _end() {
    launchUrlString("https://shannons-ultimate-machine-ranking.vercel.app/",
            mode: LaunchMode.externalApplication)
        .then((_) {
      closeIfNotMobile();
    });
  }

  final DateTime _start = DateTime.now();
  String _timeString = "00:00";

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      final random = Random();
      final size = MediaQuery.of(context).size;
      switch (random.nextInt(4)) {
        case 0:
          _pointerX = 0;
          _pointerY = 0;
          break;
        case 1:
          _pointerX = size.width - _handPointerWidth;
          _pointerY = 0;
          break;
        case 2:
          _pointerX = size.width - _handPointerWidth;
          _pointerY = size.height - _handPointerWidth;
          break;
        case 3:
          _pointerX = 0;
          _pointerY = size.height - _handPointerWidth;
          break;
      }
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        final timeString = formatDiff(DateTime.now(), _start);
        if (_move) {
          setState(() {
            _timeString = timeString;
          });
          return;
        }
        final obj = _destinationKey.currentContext?.findRenderObject();
        if (obj == null) {
          return;
        }
        if (obj is! RenderBox) {
          return;
        }
        final destination = obj.localToGlobal(Offset.zero);
        final destinationX = destination.dx;
        final diffX = destinationX - _pointerX;
        final destinationY = destination.dy - _handPointerWidth;
        final diffY = destinationY - _pointerY;
        final distance = sqrt(diffX * diffX + diffY * diffY);
        if (distance > _velocity) {
          setState(() {
            _pointerX += diffX * (_velocity / distance);
            _pointerY += diffY * (_velocity / distance);
            _timeString = timeString;
          });
          _velocity += 0.1;
        } else {
          timer.cancel();
          setState(() {
            _timeString = timeString;
          });
          sendRank(timeString).then((_) {
            _end();
          });
        }
      });
      _inited = true;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Stack(children: [
          Center(
            child: TextButton(
              onPressed: _end,
              key: _destinationKey,
              child: const Text("終了"),
            ),
          ),
          Positioned(left: 10, top: 10, child: Text(_timeString)),
          Positioned(
              left: _pointerX,
              top: _pointerY,
              child: GestureDetector(
                onTapDown: (_) {
                  _move = true;
                },
                onTapUp: (_) {
                  _move = false;
                },
                onPanStart: (_) {
                  _move = true;
                },
                onPanEnd: (_) {
                  _move = false;
                },
                onPanCancel: () {
                  _move = false;
                },
                onPanUpdate: (details) {
                  setState(() {
                    _pointerX += details.delta.dx;
                    _pointerY += details.delta.dy;
                  });
                },
                child: SizedBox(
                    width: _handPointerWidth,
                    height: _handPointerWidth,
                    child:
                        Image.asset("assets/cursor.png", fit: BoxFit.contain)),
              )),
        ]));
  }
}
