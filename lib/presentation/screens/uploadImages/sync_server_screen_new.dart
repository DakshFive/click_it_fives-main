import 'dart:io';
import 'dart:ui';
import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/common/utility.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/db_handler.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/new_database.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/local_sync_images_model.dart';
import 'package:click_it_app/data/models/photo.dart';
import 'package:click_it_app/data/models/upload_images_model.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/new_home_screen.dart';
import 'package:click_it_app/utils/constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/core/api_constants.dart';
import '../../../preferences/app_preferences.dart';
import 'package:http/http.dart' as http;

class SyncServerScreenNew extends StatefulWidget {
  const SyncServerScreenNew({Key? key}) : super(key: key);

  @override
  State<SyncServerScreenNew> createState() => _SyncServerScreenNewState();
}

class _SyncServerScreenNewState extends State<SyncServerScreenNew> {
  File? frontImage, backImage, leftImage, rightImage;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};

  late List<LocalSyncImagesModel> images;

  String imei = "";

  NewDatabaseHelper? dbHelper;
  List<Photo> imagesList = [];

  List<Map<String, dynamic>> allRowsList = [];

  bool showProgressBar = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dbHelper = NewDatabaseHelper();

    dbHelper?.queryAllRows().then((value) {
      setState(() {
        print(value);
        //print(value[0]);

        allRowsList = value;
        showProgressBar = false;
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
              const Text('Saved Images',
                style: TextStyle(fontSize: 18),

              ),
              const Spacer(),
              allRowsList.isNotEmpty ?
              GestureDetector(
                child: const Text('Sync All',
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Utils.isConnected().then((value){
                    if(value)
                      allRowsList.length > 0 ? uploadImages(allRowsList) : [];
                    else
                      Fluttertoast.showToast(
                          msg: 'Please check your internet ',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                  });

                },
              ):SizedBox(),
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
        body:
         showProgressBar?
        Center(
            child: CircularProgressIndicator(),
        ):
        allRowsList.isEmpty ?
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              SvgPicture.asset(
                  'assets/images/sync_screen_image.svg',
                  semanticsLabel: 'A red up arrow'
              ),
              Text('You have no product images(s)\n to be synced!',style: TextStyle(
                fontSize: 18,
              ),textAlign: TextAlign.center,),
            ]
          ),
        )
            :
        SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                itemCount: allRowsList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, mainIndex) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 4,bottom: 4,left: 8,right: 8),
                          child: Card(
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(" "+allRowsList[mainIndex]['gtin']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                                    child: ElevatedButton(onPressed: (){

                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(" GTIN: "+allRowsList[mainIndex]['gtin']!,
                                              style: TextStyle(
                                                fontSize: 16
                                              ),
                                            ),
                                            content: Container(
                                              width: double.minPositive,
                                              height: 350,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: 8,
                                                physics: ScrollPhysics(),
                                                itemBuilder: (context, index) {

                                                  if (index == 0) {
                                                    if(allRowsList[mainIndex]
                                                    ['frontImage'] !=
                                                    ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['frontImage'] !=
                                                                    ''
                                                                    ? Image.file(
                                                                  File(allRowsList[mainIndex]['frontImage'],
                                                                  ),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                    'Front Image',
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                    )
                                                                ),
                                                            ),

                                                          ]
                                                      );
                                                    }

                                                  } else if (index == 1) {
                                                    if(allRowsList[mainIndex]
                                                    ['backImage'] !=
                                                        '') {
                                                      return Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 10.0,
                                                            ),
                                                            height: 300,
                                                            width: 230,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius
                                                                  .circular(4),
                                                              child: allRowsList[mainIndex]
                                                              ['backImage'] !=
                                                                  ''
                                                                  ? Image.file(
                                                                  File(
                                                                      allRowsList[mainIndex]
                                                                      ['backImage']),
                                                                fit: BoxFit.scaleDown,
                                                              )

                                                                  : DottedBorder(child: SizedBox(height: 230,)),
                                                            ),
                                                          ), SizedBox(height: 10,),
                                                          Container(
                                                            margin: EdgeInsets.symmetric(
                                                              horizontal: 10.0,
                                                            ),
                                                            child: Text(
                                                                'Back Image',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.bold
                                                                )
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  } else if (index == 2) {
                                                    if(allRowsList[mainIndex]
                                                    ['leftImage'] !=
                                                        ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['leftImage'] !=
                                                                    ''
                                                                    ? Image.file(File(allRowsList[mainIndex]
                                                                ['leftImage']),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                  'Left Image',
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                  )
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }

                                                  } else if (index == 3) {
                                                    if(allRowsList[mainIndex]
                                                    ['rightImage'] !=
                                                        ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children:[
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['rightImage'] !=
                                                                    ''
                                                                    ? Image.file(File(allRowsList[mainIndex]
                                                                ['rightImage']),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                  'Right Image',
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                  )
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }

                                                  } else if (index == 4) {
                                                    if(allRowsList[mainIndex]
                                                    ['topImage'] !=
                                                        ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['topImage'] !=
                                                                    ''
                                                                    ? Image.file(File(allRowsList[mainIndex]
                                                                ['topImage']),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                  'Top Image',
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                  )
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }

                                                  } else if (index == 5) {
                                                    if(allRowsList[mainIndex]
                                                    ['bottomImage'] !=
                                                        ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['bottomImage'] !=
                                                                    ''
                                                                    ? Image.file(File(allRowsList[mainIndex]
                                                                ['bottomImage']),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                  'Bottom Image',
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                  )
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }

                                                  } else if (index == 6) {
                                                    if(allRowsList[mainIndex]
                                                    ['nutrientsImage'] !=
                                                        ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['nutrientsImage'] !=
                                                                    ''
                                                                    ? Image.file(File(allRowsList[mainIndex]
                                                                ['nutrientsImage']),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                  'Nutritional Table',
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                  )
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                    }

                                                  } else if (index == 7) {
                                                    if(allRowsList[mainIndex]
                                                    ['ingredientsImage'] !=
                                                        ''){
                                                      return Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              height: 300,
                                                              width: 230,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(4),
                                                                child: allRowsList[mainIndex]
                                                                ['ingredientsImage'] !=
                                                                    ''
                                                                    ? Image.file(File(allRowsList[mainIndex]
                                                                ['ingredientsImage']),
                                                                  fit: BoxFit.scaleDown,
                                                                )

                                                                    : DottedBorder(child: SizedBox(height: 230,)),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10,),
                                                            Container(
                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                              ),
                                                              child: Text(
                                                                  'Ingredients Image',
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.bold
                                                                  )
                                                              ),
                                                            ),
                                                          ]
                                                      );
                                                  }

                                                  }
                                                  return Container();
                                                  },
                                              )
                                            ) ,
                                          )
                                      );

                                    },style: ElevatedButton.styleFrom(
                                          minimumSize: Size.zero, // Set this
                                          padding: EdgeInsets.all(8), // and this
                                     ),
                                     child: Text('View Images')),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                                    child: ElevatedButton(onPressed: (){
                                      Utils.isConnected().then((value){
                                        if(value)
                                        uploadSingleImages(mainIndex);
                                        else
                                          Fluttertoast.showToast(
                                              msg: 'Please check your internet ',
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                      });

                                    },style: ElevatedButton.styleFrom(
                                          minimumSize: Size.zero, // Set this
                                          padding: EdgeInsets.all(8), // and this
                                     ),
                                     child: Text('Sync')),
                                  ),
                                )
                              ],
                            ),
                          )),
                      /*Container(
                        margin: EdgeInsets.only(left: 8.0,right: 8.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepOrange,width: 4)
                        ),
                        child: SizedBox(
                            height: 200.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: 8,
                              physics: ScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Stack(
                                    children: [
                                      Container(
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
                                            ? Image.file(
                                            File(allRowsList[mainIndex]['frontImage'],
                                            ),
                                          fit: BoxFit.scaleDown,
                                        )
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]
                                                    ['frontImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),
                                      Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'Front Image',
                                style: TextStyle(
                                  backgroundColor: Colors.black45,
                                  fontSize: 14,
                                  color: Colors.white
                                )
                                        ),
                                      ),
                                    ]
                                  );
                                } else if (index == 1) {
                                  return Stack(
                                    children: [
                                      Container(
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
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['backImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]['backImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'Back Image',
                                            style: TextStyle(
                                                backgroundColor: Colors.black45,
                                                fontSize: 14,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (index == 2) {
                                  return Stack(
                                    children: [
                                      Container(
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
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['leftImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]['leftImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'left Image',
                                            style: TextStyle(
                                                backgroundColor: Colors.black45,
                                                fontSize: 14,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ]
                                  );
                                } else if (index == 3) {
                                  return Stack(
                                    children:[
                                      Container(
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
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['rightImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]
                                                    ['rightImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'Right Image',
                                            style: TextStyle(
                                                backgroundColor: Colors.black45,
                                                fontSize: 14,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ]
                                  );
                                } else if (index == 4) {
                                  return Stack(
                                    children: [
                                      Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 10.0,
                                      ),
                                      width: 230,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: allRowsList[mainIndex]
                                        ['topImage'] !=
                                            ''
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['topImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]
                                                    ['rightImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),Positioned(
                                    left: 20,
                                    top: 20,
                                    right: 0,
                                    bottom: 0,
                                    child: Text(
                                        'Top Image',
                                        style: TextStyle(
                                            backgroundColor: Colors.black45,
                                            fontSize: 14,
                                            color: Colors.white
                                        )
                                    ),
                                  ),
                                    ]
                                  );
                                } else if (index == 5) {
                                  return Stack(
                                    children: [
                                      Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 10.0,
                                      ),
                                      width: 230,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: allRowsList[mainIndex]
                                        ['bottomImage'] !=
                                            ''
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['bottomImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]
                                                    ['rightImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'Bottom Image',
                                            style: TextStyle(
                                                backgroundColor: Colors.black45,
                                                fontSize: 14,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ]
                                  );
                                } else if (index == 6) {
                                  return Stack(
                                    children: [
                                      Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 10.0,
                                      ),
                                      width: 230,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: allRowsList[mainIndex]
                                        ['nutrientsImage'] !=
                                            ''
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['nutrientsImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]
                                                    ['rightImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),
                                      Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'Nutritional table',
                                            style: TextStyle(
                                                backgroundColor: Colors.black45,
                                                fontSize: 14,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ]
                                  );
                                } else if (index == 7) {
                                  return Stack(
                                    children: [
                                      Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 10.0,
                                      ),
                                      width: 230,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: allRowsList[mainIndex]
                                        ['ingredientsImage'] !=
                                            ''
                                            ? Image.file(File(allRowsList[mainIndex]
                                        ['ingredientsImage']))
                                        Utility.imageFromBase64String(
                                                allRowsList[mainIndex]
                                                    ['rightImage'])
                                            : DottedBorder(child: SizedBox(height: 230,)),
                                      ),
                                    ),
                                      Positioned(
                                        left: 20,
                                        top: 20,
                                        right: 0,
                                        bottom: 0,
                                        child: Text(
                                            'Ingredients',
                                            style: TextStyle(
                                                backgroundColor: Colors.black45,
                                                fontSize: 14,
                                                color: Colors.white
                                            )
                                        ),
                                      ),
                                    ]
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
                      ),*/
                    ],
                  );
                },
              ),
            ],
          ),
        ));
  }

  void uploadImages(List<Map<String, dynamic>> syncList) async {
    EasyLoading.show(status: 'uploading...');
    for (var i = 0; i < syncList.length; i++) {
      //upload images
      //get the saved values from the local storage in shared preferences
      final SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();
      print(_sharedPreferences.getString('company_name'));
      print(_sharedPreferences.getString('company_id'));
      print(_sharedPreferences.getString('source'));
      print(_sharedPreferences.getInt('role_id'));
      print(_sharedPreferences.getString('uid'));

      UploadImagesRequestModel requestModel = UploadImagesRequestModel(
        uid: syncList[i]['uid'],
        gtin: syncList[i]['gtin'],
        roleId: syncList[i]['roleId'].toString(),
        latitude: syncList[i]['latitude'],
        longitude: syncList[i]['longitude'],
        match: "true",
        imei: imei,
        source: syncList[i]['source'] ?? '',
        imgBack: syncList[i]['backImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['backImage']
            : '',
        imgFront: syncList[i]['frontImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['frontImage']
            : '',
        imgRight: syncList[i]['rightImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['rightImage']
            : '',
        imgLeft: syncList[i]['leftImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['leftImage']
            : '',
        imgTop: syncList[i]['topImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['topImage']
            : '',
        imgBottom: syncList[i]['bottomImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['bottomImage']
            : '',
        imgNutrient: syncList[i]['nutrientsImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['nutrientsImage']
            : '',
        imgIngredient: syncList[i]['ingredientsImage'] != ''
            ? /*"data:image/png;base64," +*/ syncList[i]['ingredientsImage']
            : '',

        // companyId: [_sharedPreferences.getString('company_id')]
      );

      var isUploaded = await uploadImagesToServer(requestModel);
      if(isUploaded){
        dbHelper!.delete(syncList[i]['gtin']);
      }
      /*Client _client = Client();
      RemoteDataSource dataSource = RemoteDataSourceImple(_client);
      dataSource.uploadImages(requestModel);*/
    }

    //delete the already saved images from the database

    /*for (var i = 0; i < allRowsList.length; i++) {
      dbHelper!.delete(allRowsList[i]['gtin']);
    }*/
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
    await dbHelper?.queryAllRows().then((value) async{
      print(value);
      //print(value[0]);

      if(value.length==0){
        print(value);
        //print(value[0]);
        await deleteLocalFiles();
      }
      /*setState(() {

          });*/
    }).catchError((error) {
      // if (Platform.isIOS) {
      //   print(error);
      // }
      /*allRowsList = [];
          deleteLocalFiles();
          print(error);*/
    });

    //EasyLoading.showSuccess('Image Uploaded Successfully');
    EasyLoading.dismiss();
    var isShowRating = await AppPreferences.getValueShared('isShowRating');
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: NewHomeScreen(isShowRatingDialog: isShowRating,),
      ),(Route<dynamic> route) => false,
    );
  }

  void uploadSingleImages(imageIndex) async {
    EasyLoading.show(status: 'uploading...');
    //for (var i = 0; i < syncList.length; i++) {
      //upload images
      //get the saved values from the local storage in shared preferences
      final SharedPreferences _sharedPreferences =
      await SharedPreferences.getInstance();
      print(_sharedPreferences.getString('company_name'));
      print(_sharedPreferences.getString('company_id'));
      print(_sharedPreferences.getString('source'));
      print(_sharedPreferences.getInt('role_id'));
      print(_sharedPreferences.getString('uid'));

      UploadImagesRequestModel requestModel = UploadImagesRequestModel(
        uid: allRowsList[imageIndex]['uid'],
        gtin: allRowsList[imageIndex]['gtin'],
        roleId: allRowsList[imageIndex]['roleId'].toString(),
        latitude: allRowsList[imageIndex]['latitude'],
        longitude: allRowsList[imageIndex]['longitude'],
        match: "true",
        imei: imei,
        source: allRowsList[imageIndex]['source'] ?? '',
        imgBack: allRowsList[imageIndex]['backImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['backImage']
            : '',
        imgFront: allRowsList[imageIndex]['frontImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['frontImage']
            : '',
        imgRight: allRowsList[imageIndex]['rightImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['rightImage']
            : '',
        imgLeft: allRowsList[imageIndex]['leftImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['leftImage']
            : '',
        imgTop: allRowsList[imageIndex]['topImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['topImage']
            : '',
        imgBottom: allRowsList[imageIndex]['bottomImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['bottomImage']
            : '',
        imgNutrient: allRowsList[imageIndex]['nutrientsImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['nutrientsImage']
            : '',
        imgIngredient: allRowsList[imageIndex]['ingredientsImage'] != ''
            ? /*"data:image/png;base64," +*/ allRowsList[imageIndex]['ingredientsImage']
            : '',

        // companyId: [_sharedPreferences.getString('company_id')]
      );

      var isUploaded = await uploadImagesToServer(requestModel);
      //var isUploaded = true;
      if(isUploaded) {

        await dbHelper!.delete(allRowsList[imageIndex]['gtin']);

        await dbHelper?.queryAllRows().then((value) {
          print(value);
          //print(value[0]);

          allRowsList = value;

          if(value.length==0){
            print(value);
            //print(value[0]);
            EasyLoading.dismiss();
            //EasyLoading.showSuccess('Image Uploaded Successfully');
            deleteLocalFiles();
            var isShowRating = AppPreferences.getValueShared('isShowRating');
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                type: PageTransitionType.leftToRight,
                child: NewHomeScreen(isShowRatingDialog: isShowRating,),
              ),(Route<dynamic> route) => false,
            );
          }else{
            EasyLoading.dismiss();
            //EasyLoading.showSuccess('Image Uploaded Successfully');
          }
          /*setState(() {

          });*/
        }).catchError((error) {
          EasyLoading.dismiss();
          //EasyLoading.showSuccess('Image Uploaded Successfully');
          // if (Platform.isIOS) {
          //   print(error);
          // }
          /*allRowsList = [];
          deleteLocalFiles();
          print(error);*/
        });

        /*Client _client = Client();
      RemoteDataSource dataSource = RemoteDataSourceImple(_client);
      dataSource.uploadImages(requestModel);*/
        // }

        //delete the already saved images from the database

        /*for (var i = 0; i < allRowsList.length; i++) {
      dbHelper!.delete(allRowsList[i]['gtin']);
    }*/
        print(
            'the current items inside the result ${dbHelper!.queryAllRows()}');

        //send the user to home screen
        //    Fluttertoast.showToast(
        // msg: 'Image Uploaded Successfully',
        // toastLength: Toast.LENGTH_SHORT,
        // gravity: ToastGravity.CENTER,
        // timeInSecForIosWeb: 1,
        // backgroundColor: Colors.red,
        // textColor: Colors.white,
        // fontSize: 16.0);

        setState(() {});
      }else{
        //EasyLoading.dismiss();
      }
    /*Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: HomeScreen(),
      ),
    );*/
  }

  Future<bool> uploadImagesToServer(UploadImagesRequestModel requestModel) async{
    final front_image =
    requestModel.imgFront;
    final back_image =
        requestModel.imgBack;
    final left_image =
        requestModel.imgLeft;
    final right_image =
        requestModel.imgRight;
    final top_image =
        requestModel.imgTop;
    final bottom_image =
        requestModel.imgBottom;
    final nutrient_image =
        requestModel.imgNutrient;
    final ingredient_image =
        requestModel.imgIngredient;
    print(front_image);
    print(back_image);
    print(left_image);
    print(right_image);
   // print(widget.gtin);
    print(AppPreferences.getValueShared('company_id'));

   /* if (front_image == null &&
        back_image == null &&
        left_image == null &&
        right_image == null) {
      // check if the data is fetched from the
      Fluttertoast.showToast(
        msg: 'click at least one product image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }*/

    //VisibleProgressLoader.show(context);

    print('+++!${AppPreferences.getValueShared('login_data')}');

    try {
      var headers = {
        'Cookie':
        'ApplicationGatewayAffinity=af22a992dad4a5c7820977e6f9af2e69; ApplicationGatewayAffinityCORS=af22a992dad4a5c7820977e6f9af2e69; PHPSESSID=d1aeelaiinjlto4slsm2mh6ot5',
        "Content-type": "multipart/form-data"
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${ApiConstants.BASE_URl}image_capture_new?apiId=${ApiConstants.API_ID}&apiKey=${ApiConstants.API_KEY}'));
      request.fields.addAll({
        'gtin': requestModel.gtin,
        'company_id':
        AppPreferences.getValueShared('source') == 'member'
            ? AppPreferences.getValueShared('company_id')
            : '',
        'uid':requestModel.uid,
        'source':requestModel.source,
        'role_id':requestModel.roleId,
        'latitude' : requestModel.latitude,
        'longitude' : requestModel.longitude,
        'imei' : imei,
        'match' : 'true'
      });

      if(front_image !=null && front_image !=''){
        request.files.add(await http.MultipartFile.fromPath('img_front',
            front_image));
      }
      if(back_image !=null && back_image !=''){
        request.files.add(await http.MultipartFile.fromPath('img_back',
            back_image));
      }
      if(left_image !=null && left_image !=''){
        request.files.add(await http.MultipartFile.fromPath('img_left',
            left_image));
      }
      if(right_image !=null && right_image !=''){
        request.files.add(await http.MultipartFile.fromPath('img_right',
            right_image));
      }
      if(top_image !=null && top_image !=''){
        request.files.add(await http.MultipartFile.fromPath('img_top',
            top_image));
      }
      if(bottom_image !=null && bottom_image !=''){
        request.files.add(await http.MultipartFile.fromPath('img_bottom',
            bottom_image));
      }
      if(ingredient_image !=null && ingredient_image !=''){
        request.files.add(await http.MultipartFile.fromPath('ingredients_image',
            ingredient_image));
      }
      if(nutrient_image !=null && nutrient_image !=''){
        request.files.add(await http.MultipartFile.fromPath('nutritional_image',
            nutrient_image));
      }

      /*front_image ==null || front_image ==''? request.fields.addAll({
        'img_front': '',
      })
          :request.files.add(await http.MultipartFile.fromPath('img_front',
          front_image));

      back_image ==null || back_image ==''? request.fields.addAll({
        'img_back': '',
      })
          :request.files.add(await http.MultipartFile.fromPath('img_back',
          back_image));

      left_image ==null || left_image ==''? request.fields.addAll({
        'img_left': '',
      })
          :request.files.add(await http.MultipartFile.fromPath('img_left',
          left_image));

      right_image ==null || right_image ==''? request.fields.addAll({
        'img_right': '',
      })
          :request.files.add(await http.MultipartFile.fromPath('img_right',
          right_image));

      ingredient_image == null || ingredient_image ==''
          ? request.fields.addAll({
        'ingredients_image': '',
      })
          : request.files.add(await http.MultipartFile.fromPath(
          'ingredients_image',ingredient_image
          ));
      nutrient_image == null|| nutrient_image ==''
          ? request.fields.addAll({
        'nutritional_image': '',
      })
          : request.files.add(await http.MultipartFile.fromPath(
          'nutritional_image',
          nutrient_image));

      top_image == null|| top_image ==''
          ? request.fields.addAll({
        'img_top': '',
      })
          : request.files.add(await http.MultipartFile.fromPath(
          'img_top',
          top_image));
      bottom_image == null|| bottom_image ==''
          ? request.fields.addAll({
        'img_bottom': '',
      })
          : request.files.add(await http.MultipartFile.fromPath(
          'img_bottom',
          bottom_image));*/

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());

        //VisibleProgressLoader.hide();
        //image uploaded successfully

        /*Fluttertoast.showToast(
          msg: 'Image Saved Successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );*/

        print('+++${AppPreferences.getValueShared('source')}');

        await ClickItConstants.reloadSharedPreference();
       /* Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),(Route<dynamic> route) => false);*/
        //EasyLoading.dismiss();
        //send the user to home screen
        return true;
      } else {
        EasyLoading.dismiss();
        print(response.reasonPhrase);
        //VisibleProgressLoader.hide();
        Fluttertoast.showToast(
            msg: 'Please try again after some time');
      }
    } on Exception catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
      //VisibleProgressLoader.hide();
      Fluttertoast.showToast(msg: e.toString());
    }
    return false;
  }
}

 Future<void> deleteLocalFiles() async {
   final directory = await getTemporaryDirectory();

   directory.deleteSync(recursive: true);

   directory.create();
 }
