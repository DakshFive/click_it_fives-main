import 'package:click_it_app/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetails extends StatefulWidget {
  const ContactDetails({Key? key}) : super(key: key);

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  final String _emailLink =
      'mailto:info@gs1india.org?subject=News&body=New%20plugin';
  final String _webUrl = 'https://www.gs1india.org';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarSidePanel(
          title: const Text('Contact Details'), appBar: AppBar()),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GS1 India'),
            SizedBox(
              height: 10.h,
            ),
            GestureDetector(
              onTap: () => _launchURL(_emailLink),
              child: RichText(
                text: const TextSpan(
                  text: 'E-mail: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'info@gs1india.org',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            GestureDetector(
              onTap: () => _launchURL(_webUrl),
              child: RichText(
                text: const TextSpan(
                  text: 'Website: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'https://www.gs1india.org/',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue),
                    ),
                    TextSpan(text: '\n'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _launchURL(String url) async {
  if (!await launch(url)) throw 'Could not launch $url';
}
