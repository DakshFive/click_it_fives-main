import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/login/login_screen.dart';
import 'package:click_it_app/screens/ratings.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../utils/app_images.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int initialIndex = 0;

  Widget _buildImage(String assetName) {
    return Image.asset(
      assetName,
      height: 300,
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;

    return IntroductionScreen(
      initialPage: initialIndex,
      onChange: (index) {
        initialIndex = index;
        setState(() {});
      },
      /*globalHeader: initialIndex != 3
          ? InkWell(
        onTap: () {
          AppPreferences.addSharedPreferences(false, "isShowTutorial");
          //go to login
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
            return LoginScreen();
          }),(Route<dynamic> route) => false);
         // RatingsScreen();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 18
            ),
          ),
        ),
      ):*/
           //Container(),
      /*globalFooter: Container(
        margin: EdgeInsets.only(right: 20),
        alignment: Alignment.topRight,
        child: arrow(),
      ),*/

      rawPages: [
        pageView("login", "login with your id password",
            AppImages.tutorial_one),
        pageView("scan barcode", "Scan your product barcode which you want to upload",
            AppImages.tutorial_two),
        pageView("click photos", "Click your product different side images.",
            AppImages.tutorial_three),
        pageView("Save locally sync later", "If you do not have internet save images locally and sync when you have internet.",
            AppImages.tutorial_four)
      ],
      curve: Curves.fastLinearToSlowEaseIn,
      controlsPadding: EdgeInsets.fromLTRB(
          8.0,
          0.0,
          8.0,
          8.0,
          /*MediaQuery.of(context).devicePixelRatio <= 2.0
              ? MediaQuery.of(context).size.height * 0.04
              : MediaQuery.of(context).size.height * 0.1*/),
      onDone: () async{
        await AppPreferences.addSharedPreferences(false, "isShowTutorial");
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
        return LoginScreen();
      }),(Route<dynamic> route) => false);
        },
      onSkip: () async{
        await AppPreferences.addSharedPreferences(false, "isShowTutorial");
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }),(Route<dynamic> route) => false);
      } ,
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text('Skip', style: TextStyle(color: Colors.deepOrange),),
      next: Icon(Icons.arrow_forward, color: Colors.deepOrange,),
      done: Text('Getting Stated', style: TextStyle(
          fontWeight: FontWeight.w600, color:Colors.deepOrange
      ),),

      dotsDecorator: DotsDecorator(
        size: Size(8.0, 8.0),
        spacing: EdgeInsets.all(4),
        activeColor: Colors.deepOrange,
        color: Colors.grey,
        activeSize: Size(8.0, 8.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  /// ------------- Tutorial Page View Widget -------------
  Widget pageView(String title, String subTitle, String image) {
    return Stack(
      children: [
        gradient(),
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              sizedBox(height: MediaQuery.of(context).size.height * 0.11),
              _buildImage(image),
              sizedBox(
                  height: MediaQuery.of(context).devicePixelRatio <= 2.5
                      ? MediaQuery.of(context).size.height * 0.055
                      : MediaQuery.of(context).size.height * 0.074),
              Center(
                child: Container(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              sizedBox(height: 8),
              Center(
                child: Container(
                    child: Text(
                      subTitle,
                      style: TextStyle(
                        fontSize: 18
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ------------- arrow  Widget -------------///
  Widget arrow() {
    return InkWell(
      onTap: () {
        AppPreferences.addSharedPreferences(false, "isShowTutorial");
        //go to login
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }),(Route<dynamic> route) => false);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.blue,
        ),
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }

  SizedBox sizedBox({double? height, double? width}) {
    return SizedBox(
      height: height ?? 0,
      width: width ?? 0,
    );
  }

  Widget gradient() {
    return Container(
      child: Image.asset(
        AppImages.gradient,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
