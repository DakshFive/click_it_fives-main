import 'dart:async';
import 'package:flutter/material.dart';

class ProgressLoader {
  static OverlayEntry? currentLoader;
  static bool isShowing = false;

  static void show(BuildContext context) {
    if (!isShowing) {
      currentLoader = OverlayEntry(
        builder: (context) => Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //  getCircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
      Overlay.of(context).insert(currentLoader!);
      isShowing = true;
    }
  }

  static void hide() {
    if (currentLoader != null) {
      currentLoader?.remove();
      isShowing = false;
    }
  }

  static getCircularProgressIndicator({double? height, double? width}) {
    height ??= 40.0;
    width ??= 40.0;
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        height: height,
        width: width,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
        ),
      ),
    );
  }

  static getErrorWidget() {
    return Container(
      alignment: Alignment.center,
      child: const SizedBox(
        height: 40.0,
        width: 40.0,
        child: Text("Oops! Something went wrong."),
      ),
    );
  }
}

class CircularLoading extends StatefulWidget {
  final double height;

  const CircularLoading({required this.height});

  @override
  _CircularLoadingState createState() => _CircularLoadingState();
}

class _CircularLoadingState extends State<CircularLoading>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  bool error = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          error = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: !error
            ? const CircularProgressIndicator()
            : const Text(
                "No Record's Found",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
      ),
    );
  }
}

class CircularLoading1 extends StatefulWidget {
  final double height;

  CircularLoading1({required this.height});

  @override
  _CircularLoading1State createState() => _CircularLoading1State();
}

class _CircularLoading1State extends State<CircularLoading1>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  bool error = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          error = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: !error
            ? const CircularProgressIndicator()
            : const Text(
                " ",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
      ),
    );
  }
}
