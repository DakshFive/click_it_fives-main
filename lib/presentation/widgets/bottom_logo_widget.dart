import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomLogoWidget extends StatelessWidget {
  const BottomLogoWidget({
    Key? key,
  }) : super(key: key);

  final String _url = 'https://www.gs1india.org/datakart';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      margin: EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          const Positioned(
            top: 35,
            left: 0,
            right: 20,
            bottom: 5,
            child: Text(
              'Powered by',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Image(
            image: const AssetImage(
              'assets/images/logo_datakart.png',
            ),
            width: 150.w,
            height: 150.h,
          ),
          const Positioned(
            right: 0,
            top: 80,
            child: Text(
              'by GS1 India',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 20,
             child: GestureDetector(
              onTap: () => _launchURL(_url),
              child: const Text(
                'www.gs1india.org/datakart',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _launchURL(String url) async {
  if (!await launch(url)) throw 'Could not launch $url';
}
