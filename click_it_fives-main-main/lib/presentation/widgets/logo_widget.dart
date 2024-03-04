import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage('assets/images/logo_datakart.png'),
          fit: BoxFit.fitWidth,
        ),
        SizedBox(
          height: 10.h,
        ),
        const Text(
          'Click It',
          style: TextStyle(fontSize: 20, color: Color(0xffe66e4e),fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
