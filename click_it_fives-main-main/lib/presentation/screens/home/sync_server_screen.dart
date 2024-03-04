import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/common/utility.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/db_handler.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/local_sync_images_model.dart';
import 'package:click_it_app/data/models/photo.dart';
import 'package:click_it_app/data/models/upload_images_model.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncServerScreen extends StatefulWidget {
  const SyncServerScreen({Key? key}) : super(key: key);

  @override
  State<SyncServerScreen> createState() => _SyncServerScreenState();
}

class _SyncServerScreenState extends State<SyncServerScreen> {
  File? frontImage, backImage, leftImage, rightImage;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};

  late List<LocalSyncImagesModel> images;

  String imei = "";

  DatabaseHelper? dbHelper;
  List<Photo> imagesList = [];

  List<Map<String, dynamic>> allRowsList = [];

  bool showProgressBar = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dbHelper = DatabaseHelper();

    dbHelper?.queryAllRows().then((value) {
      setState(() {
        print(value);
        print(value[0]);

        allRowsList = value;
      });
    }).catchError((error) {
      // if (Platform.isIOS) {
      //   print(error);
      // }

      print(error);
    });

    //getDeviceImei();
  }

  Future<void> getDeviceImei() async {
    try {
      if (Platform.isAndroid) {
        deviceData =
            Utils.readAndroidBuildData(await deviceInfoPlugin.androidInfo);

        imei = deviceData['androidId'];
      } else {
        deviceData = Utils.readIosDeviceInfo(await deviceInfoPlugin.iosInfo);

        imei = deviceData['identifierForVendor'];
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: const Text('Saved Images'),
          // elevation: 0,

          // actions: [const Text('Sync')],
          title: Row(
            children: [
              const Text('Saved Images'),
              const Spacer(),
              GestureDetector(
                child: const Text('Sync'),
                onTap: () {
                  allRowsList.length > 0 ? uploadImages() : null;
                },
              ),
            ],
          ),
          titleTextStyle: const TextStyle(
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              ListView.builder(
                itemCount: allRowsList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, mainIndex) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(allRowsList[mainIndex]['gtin']!)),
                      SizedBox(
                          height: 230.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 4,
                            physics: ScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 10.0,
                                  ),
                                  width: 230,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: allRowsList[mainIndex]
                                                ['frontImage'] !=
                                            ''
                                        ? Utility.imageFromBase64String(
                                            allRowsList[mainIndex]
                                                ['frontImage'])
                                        : DottedBorder(child: SizedBox()),
                                  ),
                                );
                              } else if (index == 1) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 10.0,
                                  ),
                                  width: 230,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: allRowsList[mainIndex]
                                                ['backImage'] !=
                                            ''
                                        ? Utility.imageFromBase64String(
                                            allRowsList[mainIndex]['backImage'])
                                        : DottedBorder(child: SizedBox()),
                                  ),
                                );
                              } else if (index == 2) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 10.0,
                                  ),
                                  width: 230,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: allRowsList[mainIndex]
                                                ['leftImage'] !=
                                            ''
                                        ? Utility.imageFromBase64String(
                                            allRowsList[mainIndex]['leftImage'])
                                        : DottedBorder(child: SizedBox()),
                                  ),
                                );
                              } else if (index == 3) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 10.0,
                                  ),
                                  width: 230,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: allRowsList[mainIndex]
                                                ['rightImage'] !=
                                            ''
                                        ? Utility.imageFromBase64String(
                                            allRowsList[mainIndex]
                                                ['rightImage'])
                                        : DottedBorder(child: SizedBox()),
                                  ),
                                );
                              }
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 10.0,
                                ),
                                width: 230,
                                color: Colors.yellowAccent,
                                child: Text(
                                    ' mainIndex${[mainIndex]} index${index}'),
                              );
                            },
                          )),
                    ],
                  );
                },
              ),
            ],
          ),
        ));
  }

  void uploadImages() async {
    EasyLoading.show(status: 'uploading...');
    for (var i = 0; i < allRowsList.length; i++) {
      //upload images
      //get the saved values from the local storage in shared preferences
      final SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();
      print(_sharedPreferences.getString('company_name'));
      print(_sharedPreferences.getString('company_id'));
      print(_sharedPreferences.getString('source'));
      print(_sharedPreferences.getInt('role_id'));
      print(_sharedPreferences.getString('uid'));

      /*UploadImagesRequestModel requestModel = UploadImagesRequestModel(
        uid: '',
        gtin: allRowsList[i]['gtin'],
        roleId: _sharedPreferences.getInt('role_id').toString(),
        latitude: allRowsList[i]['latitude'],
        longitude: allRowsList[i]['longitude'],
        match: "true",
        imei: imei,
        source: _sharedPreferences.getString('source')!,
        imgBack: allRowsList[i]['backImage'] != ''
            ? "data:image/png;base64," + allRowsList[i]['backImage']
            : '',
        imgFront: allRowsList[i]['frontImage'] != ''
            ? "data:image/png;base64," + allRowsList[i]['frontImage']
            : '',
        imgRight: allRowsList[i]['rightImage'] != ''
            ? "data:image/png;base64," + allRowsList[i]['rightImage']
            : '',
        imgLeft: allRowsList[i]['leftImage'] != ''
            ? "data:image/png;base64," + allRowsList[i]['leftImage']
            : '',

        // companyId: [_sharedPreferences.getString('company_id')]
      );*/

      Client _client = Client();
      RemoteDataSource dataSource = RemoteDataSourceImple(_client);
      //dataSource.uploadImages(requestModel);
    }

    //delete the already saved images from the database

    for (var i = 0; i < allRowsList.length; i++) {
      dbHelper!.delete(allRowsList[i]['gtin']);
    }
    print('the current items inside the result ${dbHelper!.queryAllRows()}');

    //send the user to home screen
    //    Fluttertoast.showToast(
    // msg: 'Image Uploaded Successfully',
    // toastLength: Toast.LENGTH_SHORT,
    // gravity: ToastGravity.CENTER,
    // timeInSecForIosWeb: 1,
    // backgroundColor: Colors.red,
    // textColor: Colors.white,
    // fontSize: 16.0);
    EasyLoading.showSuccess('Image Uploaded Successfully');
    EasyLoading.dismiss();

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: HomeScreen(isShowRatingDialog: false),
      ),
    );
  }
}
