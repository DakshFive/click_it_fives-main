import 'package:click_it_app/presentation/screens/sidepanel/contact_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../preferences/app_preferences.dart';
import '../../../utils/app_images.dart';
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
  String? companyName, companyId;
  
  @override
  void initState() {
    AppPreferences.init();
    getCompanyDetails();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          Center(
            child: Text(companyId != ''
                ? '$companyName ($companyId)'
                : '$companyName',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.backgroundImage),
              fit: BoxFit.cover,
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 8,
            ),
            Flexible(
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: Card(
                      child: ListTile(
                        onTap: () => Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: const AboutUs(),
                            )),
                        title: Row(
                            children: [
                              ImageIcon(
                                AssetImage(AppImages.about_icon),
                                color: Colors.black,),
                              SizedBox(width: 10,),
                              const Text('About Us',
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                            ]),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: ContactDetails(),
                          )),
                      title: Row(
                          children: [
                            Icon(Icons.contact_mail,color: Colors.black,),
                            SizedBox(width: 10,),
                            const Text('Contact Details',
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ]),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const DisclaimerScreen(),
                        ),
                      ),
                      title: Row(
                          children: [
                            ImageIcon(AssetImage(AppImages.disclaimer_icon,),color: Colors.black,),
                            SizedBox(width: 10,),
                            const Text('Disclaimer',
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ]),
                      /*const Text('Disclaimer',
                          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),*/
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () => Share.share(
                        'check out my website https://www.gs1india.org/datakart',
                        subject: 'Please download ClickIt app',
                      ),
                      title: Row(
                          children: [
                            Icon(Icons.share,color: Colors.black,),
                            SizedBox(width: 10,),
                            const Text('Share App',
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ]),
                      /*const Text('Share App'
                      ,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),*/
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        showLogoutAlert();
                      },

                      title:Row(
                          children: [
                            Icon(Icons.logout,color: Colors.black,),
                            SizedBox(width: 10,),
                            const Text('Logout',
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ]),
                      /*const Text('Logout',
                        style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),*/
                    ),
                  ),
                   ListTile(
                    title: Center(
                      child:  Text('Version 1.0.0',
                        style: TextStyle(color: Colors.black
                            ,fontWeight: FontWeight.bold,
                            backgroundColor: Colors.deepOrange.withAlpha(70)),),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            /*Stack(
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
            ),*/
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

  getCompanyDetails() async {
    final SharedPreferences _sharedPreferences =
    await SharedPreferences.getInstance();
    String? company_name = _sharedPreferences.getString('company_name');
    String? company_id = _sharedPreferences.getString('company_id');

    setState(() {
      companyName = company_name;
      companyId = company_id;
      print(companyName);
    });
  }
  
  showLogoutAlert()
  {
    showDialog(
        context: context,
        builder: (context) {

            return AlertDialog(
              title: Text('Logout'),
              content:  Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.start,
                  style:  TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                  )
              ),
              actions: [
                TextButton(onPressed: (){

                  Navigator.pop(context);
                }, child: Text('Cancel')),

                TextButton(onPressed: () async{

                  final SharedPreferences _sharedPreferences =
                      await SharedPreferences.getInstance();


                  _sharedPreferences.clear().whenComplete(
                        () {
                          AppPreferences.addSharedPreferences(false, "isShowTutorial");
                          Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                child: const LoginScreen(),
                                type: PageTransitionType.leftToRight,

                              ),(Route<dynamic> route) => false
                          );
                        }

                  );

                }, child: Text('Ok')),


              ],
            );


        });
  }
}