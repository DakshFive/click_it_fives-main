import 'dart:convert';
import 'dart:ui';

import 'package:click_it_app/app_tutorial_coach/tutorial_home_coach.dart';
import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/home/new_uploadscreen.dart';
import 'package:click_it_app/presentation/screens/home/sync_server_screen.dart';
import 'package:click_it_app/presentation/screens/home/upload_images_screen.dart';

import 'package:click_it_app/presentation/screens/login/login_screen.dart';
import 'package:click_it_app/presentation/screens/notification/notification_screen.dart';
import 'package:click_it_app/presentation/screens/sidepanel/about_us_screen.dart';
import 'package:click_it_app/presentation/screens/sidepanel/contact_screen.dart';
import 'package:click_it_app/presentation/screens/sidepanel/disclaimer_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/new_upload_images_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/sync_server_screen_new.dart';
import 'package:click_it_app/presentation/widgets/bottom_logo_widget.dart';
import 'package:click_it_app/presentation/widgets/logo_widget.dart';
import 'package:click_it_app/screens/rating_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../common/loader/visible_progress_loaded.dart';
import '../../../utils/app_images.dart';
import '../../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.isShowRatingDialog}) : super(key: key);
  final isShowRatingDialog;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  //late TutorialCoachMark tutorialCoachMark;

  //GlobalKey scanBarcodeKey = GlobalKey();

  String? companyName, companyId;

  @override
  void initState() {
    // TODO: implement initState
    /*createTutorial();
      Future.delayed(Duration.zero, showTutorial);*/

    getCompanyDetails();

    if(widget.isShowRatingDialog){
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showDialog(
          useSafeArea: true,
          context: context,
          barrierDismissible: true, // set to false if you want to force a rating
          builder: (context) => RatingScreenCustom(),
        );
      });
    }

    AppPreferences.addSharedPreferences(false, ClickItConstants.frontImageUploadedKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.backImageUploadedKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.leftImageUploadedKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.rightImageUploadedKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.topImageUploadedKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.bottomImageUploadedKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.nutrientsUploadedImageKey);
    AppPreferences.addSharedPreferences(false, ClickItConstants.ingredientImageUploadedKey);

    /*AppPreferences.addSharedPreferences(false,ClickItConstants.frontImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.backImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.topImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.bottomImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.rightImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.leftImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.nutrientsImageProcessing);
        AppPreferences.addSharedPreferences(false,ClickItConstants.ingredientImageProcessing);*/
    super.initState();
  }

  bool isNumeric(String str) {
    final numericValue = double.tryParse(str);
    return numericValue != null;
  }



  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          /*endDrawer: AppDrawer(),*/
          appBar: AppBar(
            title: Text(
              companyId != ''
                  ? '$companyName ($companyId)'
                  : '$companyName',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Badge(
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  label: Text('4',style: TextStyle(color: Colors.deepOrange),),
                  alignment: Alignment.topRight,
                  backgroundColor: Colors.white,
                  offset: Offset.fromDirection(6,8)
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: NotificationScreen(),
                    ),
                  );
                },
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
            child:  Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                /*Container(
                  margin: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        companyId != ''
                            ? '$companyName ($companyId)'
                            : '$companyName',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.deepOrange,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        child: const Icon(
                          Icons.keyboard_arrow_left_sharp,
                          size: 35,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),*/
                SizedBox(
                  height: 20.h,
                ),
                const LogoWidget(),
                SizedBox(
                  height: 20.h,
                ),
                GestureDetector(
                  // ignore: avoid_print
                  onTap: () => _scanBarcode().then(
                    (value) async{
                      if (value != null) {
                        var glnValue = value;
                        if(value.contains('http')) {
                          Utils.isConnected().then((isConnected) async{
                              if(isConnected){
                                VisibleProgressLoader.show(context);
                                glnValue = await decodeQrCode(value);
                              }else{
                                Fluttertoast.showToast(
                                    msg: 'Please check your internet');
                              }
                          });

                        }

                        if(glnValue!=AppPreferences.getValueShared('currentGtn')) {

                          await ClickItConstants.reloadSharedPreference();

                          AppPreferences.addSharedPreferences(false, ClickItConstants.frontImageUploadedKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.backImageUploadedKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.leftImageUploadedKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.rightImageUploadedKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.topImageUploadedKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.bottomImageUploadedKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.nutrientsUploadedImageKey);
                          AppPreferences.addSharedPreferences(false, ClickItConstants.ingredientImageUploadedKey);
                         }


                          if ((glnValue.length == 13 || glnValue.length==14) && isNumeric(glnValue)) {
                            AppPreferences.addSharedPreferences(value, 'currentGtn');
                            print(value);
                            if (AppPreferences.getValueShared('source') ==
                                'member') {
                              // user is manufacturer
                              // validate barcodes for manufacturer

                              print('user is manufacturer');

                              print(value.toString().substring(
                                  0,
                                  AppPreferences.getValueShared('company_id')
                                      .length));

                              if (glnValue.toString().substring(
                                  0,
                                  AppPreferences.getValueShared('company_id')
                                      .length) ==
                                  AppPreferences.getValueShared('company_id')) {
                                print('success');
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: NewUploadImagesScreen(gtin: glnValue),
                                  ),
                                );
                              } else {
                                //in manufacturer the barcodes are not validated
                                //D-Here add new change
                                Fluttertoast.showToast(
                                    msg: 'This is not your GTN. Please scan your GTN');
                              }
                            } else {
                              //user is retailer all the barcodes will be scanned
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: NewUploadImagesScreen(gtin: glnValue),
                                ),
                              );
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Scanned Barcode is invalid');
                          }

                      }

                      // value == -1
                      //     ? Navigator.pop(context)
                      //     : Navigator.push(
                      //         context,
                      //         PageTransition(
                      //           type: PageTransitionType.rightToLeft,
                      //           child: UploadImagesScreen(
                      //             scanResult: value,
                      //           ),
                      //         ));
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      key:HomeCoach.getKey(),
                      children: const [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.deepOrange,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Scan product barcode',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                /*const SizedBox(
                  height: 10,
                ),
                const Text(
                  'or',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),*/
                /*GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: SyncServerScreenNew(),
                    ),
                  ),

                  // onTap: () {

                  //   // Utils.showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
                  //   _dialog.show(type: SimpleFontelicoProgressDialogType.spinner, message: '');
                  // },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(13),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: const Text(
                      'Sync with Server',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                Spacer(),
                BottomLogoWidget(),*/
              ],
            ),
          )),
    );
  }

  Future _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      print('the value of bracode is $barcodeScanRes');
      return barcodeScanRes == '-1' ? null : barcodeScanRes;
    } on Exception catch (e) {
      print(e);
    }
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

  /*void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.deepOrange,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    *//*targets.add(
      TargetFocus(
        identify: "homeNavigation",
        keyTarget: homeKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Here you can simply scan barcode of product",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "saveImageNavigation",
        keyTarget: localImageKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Here you can see saved clicked images",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "viewLibraryNavigation",
        keyTarget: viewLibraryKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Here you can see all the uploaded images",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "settingsNavigation",
        keyTarget: settingsKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Here you can see information",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );*//*

    *//*targets.add(
      TargetFocus(
        identify: "scanBarcodeKey",
        keyTarget: scanBarcodeKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Scan your product barcode",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                 *//**//* Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),*//**//*
                ],
              );
            },
          ),
        ],
      ),
    );*//*
    targets.add(
      TargetFocus(
        identify: "scanBarcodeKey",
        keyTarget: scanBarcodeKey,
        color: Colors.deepOrange,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Scan your product barcode",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  *//*const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),*//*
                  *//*ElevatedButton(
                    onPressed: () {
                      controller.previous();
                    },
                    child: const Icon(Icons.chevron_left),
                  ),*//*
                ],
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );
    *//*targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton,
        color: Colors.purple,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Titulo lorem ipsum",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.previous();
                    },
                    child: const Icon(Icons.chevron_left),
                  ),
                ],
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Target 2",
        keyTarget: keyButton4,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Multiples content",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          TargetContent(
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Multiples content",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ))
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(TargetFocus(
      identify: "Target 3",
      keyTarget: keyButton5,
      contents: [
        TargetContent(
            align: ContentAlign.right,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Title lorem ipsum",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 4",
      keyTarget: keyButton3,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  tutorialCoachMark.previous();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.network(
                    "https://juststickers.in/wp-content/uploads/2019/01/flutter.png",
                    height: 200,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "Image Load network",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(
      TargetFocus(
        identify: "Target 5",
        keyTarget: keyButton2,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "Multiples contents",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          TargetContent(
              align: ContentAlign.bottom,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Multiples contents",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ))
        ],
      ),
    );*//*

    return targets;
  }*/
}
Future decodeQrCode(String value) async {
  var request = await http.Request('POST',
      Uri.parse(
          'http://4.240.61.161:8081/decodeUrl'));
  request.body = json.encode({"elementStringInput": value});
  request.headers.addAll({"Content-Type": "application/json"});
  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    final glnData = await response.stream.bytesToString();

    var glnValue = jsonDecode(glnData)['01']['value'];
    VisibleProgressLoader.hide();
    return glnValue;
  }
  VisibleProgressLoader.hide();
  return "";
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // margin: const EdgeInsets.only(
        //   right: 10,
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const Divider(),
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


