import 'package:flutter/material.dart';

class AppBarSidePanel extends StatelessWidget implements PreferredSizeWidget {
  const AppBarSidePanel({
    Key? key,
    required this.title,
    required this.appBar,
  }) : super(key: key);
  final Color backgroundColor = Colors.deepOrange;
  final Text title;
  final AppBar appBar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
