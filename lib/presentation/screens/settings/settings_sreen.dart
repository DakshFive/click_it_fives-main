import 'package:click_it_app/presentation/screens/sidepanel/contact_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_screen.dart';
import '../sidepanel/about_us_screen.dart';
import '../sidepanel/disclaimer_screen.dart';

class SettingsScreen extends StatefulWidget{

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() {
    return _SettingsScreenState();
  }

}

class _SettingsScreenState extends State<SettingsScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        // margin: const EdgeInsets.only(
        //   right: 10,
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 15,
            ),
            Flexible(
              child: ListView(
                children: [
                  ListTile(
                    onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const AboutUs(),
                        )),
                    title: const Text('About Us'),
                  ),
                  ListTile(
                    onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ContactDetails(),
                        )),
                    title: const Text('Contact Details'),
                  ),
                  ListTile(
                    onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const DisclaimerScreen(),
                      ),
                    ),
                    title: const Text('Disclaimer'),
                  ),
                  ListTile(
                    onTap: () => Share.share(
                      'check out my website https://www.gs1india.org/datakart',
                      subject: 'Please download ClickIt app',
                    ),
                    title: const Text('Share App'),
                  ),
                  ListTile(
                    onTap: () async {
                      final SharedPreferences _sharedPreferences =
                      await SharedPreferences.getInstance();

                      _sharedPreferences.clear().whenComplete(
                            () => Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: const LoginScreen(),
                            type: PageTransitionType.leftToRight,
                          ),
                        ),
                      );
                    },
                    title: const Text('Logout'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 20,
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                Image(
                  image: AssetImage(
                    'assets/images/img_sidepanel.png',
                  ),
                ),
              ],
            ),
          ],
        ),
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/images/logo_datakart.png'),
        //   ),
        // ),
      ),
    );
  }

}