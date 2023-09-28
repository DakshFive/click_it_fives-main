import 'dart:async';
import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/home/upload_images_screen.dart';
import 'package:click_it_app/presentation/screens/login/login_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/new_home_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/new_upload_images_screen.dart';
import 'package:click_it_app/presentation/widgets/bottom_logo_widget.dart';
import 'package:click_it_app/presentation/widgets/logo_widget.dart';
import 'package:click_it_app/presentation/widgets/rating_widget.dart';
import 'package:click_it_app/screens/rating_screen.dart';
import 'package:click_it_app/screens/ratings.dart';
import 'package:click_it_app/tutorial/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? finalUserName;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isbarcodeScanned;
  String? currentGTIN;

  bool isUserExist = false;
  bool isShowTutorial = false;

  @override
  void initState() {
    super.initState();

    checkUserExist();

    Timer(
      const Duration(seconds: 3),
      () {
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return //RatingScreenCustom();
            isShowTutorial ? TutorialScreen()
                : !isUserExist
                ? LoginScreen()
                : isbarcodeScanned == false
                    ? NewHomeScreen(isShowRatingDialog: false,)
                    : currentGTIN == null
                        ? NewHomeScreen(isShowRatingDialog: false,)
                        : NewUploadImagesScreen(gtin: currentGTIN!);
          },
        ),
      );
  }
    );
  }

  Future getValidationData() async {
    var obtainedUserName = AppPreferences.getValueShared('company_name');

    setState(() {
      finalUserName = obtainedUserName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Spacer(),
                LogoWidget(),
                Spacer(),
                BottomLogoWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  checkUserActivity() async{
    isbarcodeScanned = AppPreferences.getValueShared('isImageUploaded');
    currentGTIN = AppPreferences.getValueShared('gtin');
    await checkTutorialShow();
  }

  checkUserExist() async{
    await AppPreferences.init();
    print('____${AppPreferences.getValueShared('login_data')}');
    isUserExist = AppPreferences.getValueShared('login_data') == null
        ? false
        : true;

    await checkUserActivity();
  }

  checkTutorialShow() async{
    isShowTutorial = AppPreferences.getValueShared('isShowTutorial') == null
        ? true
        : false;
  }


}
