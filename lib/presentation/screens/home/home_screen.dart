import 'dart:convert';

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

  String? companyName, companyId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
                fontSize: 14,
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
                          String userName =
                               AppPreferences.getValueShared('company_id');
                          String company_name =
                               AppPreferences.getValueShared('company_name');

                          String userRole =
                               AppPreferences.getValueShared('login_data');

                          dynamic retrievedData =
                               AppPreferences.getValueShared('login_data');

                          bool isShowRating =
                          await AppPreferences.getValueShared('isShowRating') == null
                              ? true : AppPreferences.getValueShared('isShowRating');

                          var uid = AppPreferences.getValueShared('uid');

                          String source = AppPreferences.getValueShared('source');
                          var roleId = AppPreferences.getValueShared('role_id');

                          AppPreferences.clearSharedPreferences();

                          AppPreferences.addSharedPreferences(
                              uid, 'uid');

                          AppPreferences.addSharedPreferences(
                              source, 'source');

                          AppPreferences.addSharedPreferences(
                              roleId, 'role_id');


                          AppPreferences.addSharedPreferences(userName, 'company_id');
                          AppPreferences.addSharedPreferences(
                              company_name, 'company_name');
                          AppPreferences.addSharedPreferences(false, 'isImageUploaded');
                          AppPreferences.addSharedPreferences(userName, 'company_id');
                          AppPreferences.addSharedPreferences(userRole, 'source');
                          AppPreferences.addSharedPreferences(
                              retrievedData, 'login_data');
                          AppPreferences.addSharedPreferences(false, "isShowTutorial");
                          AppPreferences.addSharedPreferences(isShowRating, "isShowRating");
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
