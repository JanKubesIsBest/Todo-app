// ignore: deprecated_member_use
import 'dart:ui' show Canvas, Offset, Size, TextDirection, window;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfuckyourlife/components/homePage/HomePage.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key, required this.title});

  final String title;

  @override
  State<InitialPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<InitialPage>
    with TickerProviderStateMixin {
  int turn = 0;

  late Animation<double> animation;
  late AnimationController controller;

  late Animation<double> animationOpacity;

  late Animation<double> widgetAnimationOpacity;
  late AnimationController widgetController;

  late Animation<double> buttonAnimationOpacity;
  late AnimationController buttonController;

  final TextEditingController nameControler = TextEditingController();

  late final SharedPreferences prefs;

  TimeOfDay defaultTimeForNotifying = const TimeOfDay(hour: 12, minute: 0);

  final words = [
    "Hello",
    "What's your name?",
    "How are you feeling?",
    "How satisfied are you with your life?",
    "Me and my team have concluded",
    "that you can fix your life through discipline.",
    "There are 3 core rutines you should follow.",
    "To make your life better."
  ];

  double feeling = 50.0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    widgetController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    buttonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    Tween<double> doubleTweenOpacity = Tween<double>(
      begin: 0,
      end: 1,
    );

    widgetAnimationOpacity = doubleTweenOpacity.animate(
        CurvedAnimation(parent: widgetController, curve: Curves.linear))
      ..addListener(() {
        setState(() {});
      });
    buttonAnimationOpacity = doubleTweenOpacity.animate(
        CurvedAnimation(parent: buttonController, curve: Curves.linear))
      ..addListener(() {
        setState(() {});
      });

    setPrefs();
    nextAnim();
  }

  @override
  void dispose() {
    controller.dispose();
    buttonController.dispose();
    widgetController.dispose();
    super.dispose();
  }

  void nextAnim() {
    Tween<double> doubleTween = Tween<double>(
      begin: (window.physicalSize.longestSide / window.devicePixelRatio) / 4,
      end: (window.physicalSize.longestSide / window.devicePixelRatio) / 3,
    );

    Tween<double> doubleTweenOpacity = Tween<double>(
      begin: 0,
      end: 1,
    );

    animation = doubleTween
        .animate(CurvedAnimation(parent: controller, curve: Curves.decelerate))
      ..addListener(() {
        setState(() {});
      });

    animationOpacity = doubleTweenOpacity
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          if (turn == words.length - 1) {
            buttonController.forward();
            return;
          }
          await Future.delayed(const Duration(milliseconds: 1300));
          controller.reverse().whenComplete(() => {
                if (turn < words.length - 1)
                  {
                    nextAnim(),
                    turn++,
                    if (turn == 1)
                      {
                        widgetController.forward(),
                      }
                  }
              });
        }
      });

    controller.forward();
  }

  void setPrefs() async {
    prefs = await SharedPreferences.getInstance();
    // Time of a day will be set as hours/minutes in prefs...
    prefs.setString("defaultNotifyingTime", "${defaultTimeForNotifying.hour}/${defaultTimeForNotifying.minute}");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomPaint(
        painter: Painter(
            yPosition: animation.value,
            opacity: animationOpacity.value,
            word: words[turn]),
        child: Opacity(
          opacity: widgetAnimationOpacity.value,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: window.physicalSize.longestSide /
                          window.devicePixelRatio /
                          3 +
                      200,
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  controller: nameControler,
                  onChanged: (value) async {
                    prefs.setString("name", value);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'How are you feeling in one word?',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "How satisfied are you with your life?",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.left,
                ),
                Slider(
                  value: feeling,
                  onChanged: (double x) {
                    setState(() {
                      feeling = x;
                    });
                  },
                  max: 100,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  // TODO: Add something along these lines: "Default time should be time when you have free hours (after work, after school)"
                  child: Text(
                    'When do you want to be notified: ${defaultTimeForNotifying.format(context)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                        fontSize: 15),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Opacity(
                  opacity: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () async {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    },
                    child: const Text(
                      "Start a new life",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontSize: 30),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked_s = await showTimePicker(
      context: context,
      initialTime: defaultTimeForNotifying,
    );

    if (picked_s != null && picked_s != defaultTimeForNotifying) {
      setState(() {
        defaultTimeForNotifying = picked_s;
      });
      prefs.setString("defaultNotifyingTime", "${defaultTimeForNotifying.hour}/${defaultTimeForNotifying.minute}");
    }
  }
}

class Painter extends CustomPainter {
  final double yPosition;
  final double opacity;
  final String word;

  Painter({
    super.repaint,
    required this.word,
    required this.yPosition,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var textStyle = TextStyle(
      color: Colors.white.withOpacity(opacity),
      fontSize: 50,
      fontWeight: FontWeight.w100,
    );
    var textSpan = TextSpan(
      text: word,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(canvas, Offset(20, yPosition));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
