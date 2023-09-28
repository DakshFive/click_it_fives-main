import 'package:click_it_app/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBarSidePanel(title: const Text('Disclaimer'), appBar: AppBar()),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            RichText(
              text: const TextSpan(
                text: '• ',
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'Product information and product images displayed in the',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: ' \'ClickIt\' ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text:
                        'mobile app has been provided by the product\'s manufacturer/supplier through GS1 India\'s DataKart, and only they (manufacturer/supplier) are responsible for the information\'s completeness and accuracy.',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            RichText(
              text: const TextSpan(
                text: '• ',
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'GS1 India are not responsible for completeness and accuracy of product data and images displayed through this app.',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
