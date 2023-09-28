import 'package:flutter/material.dart';

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PageView(
        /// [PageView.scrollDirection] defaults to [Axis.horizontal].
        /// Use [Axis.vertical] to scroll vertically.
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: const <Widget>[
          Center(
            child: Text('First Page'),
          ),
          Center(
            child: Text('Second Page'),
          ),
          Center(
            child: Text('Third Page'),
          ),
        ],
      ),
    );
  }
}
