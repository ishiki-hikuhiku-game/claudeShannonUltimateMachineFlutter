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

/// 徐々に大きくなる振動
/// 0.1t^2 sin(10t) ふり幅は小さく、周期は早く
/// の導関数
/// (0.1t^2 sin(10 * t))' = 0.1(t^2)' sin(10t) + 0.1t^2 (sin(10t))' = 0.2 t sin(10t) + 0.1 t^2 * 10 cos(10t) = 0.2tsin(10t) + t^2 cos(10t)
double force(double t) {
  return 0.2 * t * sin(10 * t) + t * t * cos(10 * t);
}

class _MyHomePageState extends State<MyHomePage> {
  double _pointerX = 0.0;
  double _pointerY = 0.0;
  double _tapX = 0.0;
  double _tapY = 0.0;
  final _handPointerWidth = 60.0;
  double _velocity = 0.0;
  bool _inited = false;

  /// タップやクリックによって捕まえられている状態
  bool _captured = false;
  double _moveCounter = 0.0;
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
        if (_captured) {
          _moveCounter += 0.1;
          final pointerTapDiffX = _pointerX - _tapX;
          final pointerTapDiffY = _pointerY - _tapY;
          final pointerTapDistance = sqrt(pointerTapDiffX * pointerTapDiffX +
              pointerTapDiffY * pointerTapDiffY);
          if (pointerTapDistance > 150) {
            _captured = false;
          }
          final f = force(_moveCounter);
          setState(() {
            _pointerX += f;
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
                onTapDown: (details) {
                  _tapX = details.globalPosition.dx;
                  _tapY = details.globalPosition.dy;
                  _moveCounter = 0.0;
                  _captured = true;
                },
                onTapUp: (_) {
                  _captured = false;
                },
                onPanStart: (details) {
                  _tapX = details.globalPosition.dx;
                  _tapY = details.globalPosition.dy;
                  _moveCounter = 0.0;
                  _captured = true;
                },
                onPanEnd: (_) {
                  _captured = false;
                },
                onPanCancel: () {
                  _captured = false;
                },
                onPanUpdate: (details) {
                  if (_captured) {
                    _tapX += details.delta.dx;
                    _tapY += details.delta.dy;
                    setState(() {
                      _pointerX += details.delta.dx;
                      _pointerY += details.delta.dy;
                    });
                  }
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
