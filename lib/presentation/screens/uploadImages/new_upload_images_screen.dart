

import 'dart:io';

import 'package:click_it_app/app_tutorial_coach/tutorial_save_data_coach.dart';
import 'package:click_it_app/common/loader/progressLoader.dart';
import 'package:click_it_app/common/loader/visible_progress_loaded.dart';
import 'package:click_it_app/controllers/upload_images_provider.dart';
import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/back_image_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/front_image_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/ingredients.dart';
import 'package:click_it_app/presentation/screens/uploadImages/left_image_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/new_home_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/nutritional_value.dart';
import 'package:click_it_app/presentation/screens/uploadImages/right_image_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/top_image_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/bottom_image_screen.dart';
import 'package:click_it_app/utils/constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../app_tutorial_coach/tutorial_upload_coach.dart';
import '../../../common/Utils.dart';
import '../../../common/utility.dart';
import '../../../data/core/api_constants.dart';
import '../../../data/data_sources/Local Datasource/new_database.dart';
import '../../../data/data_sources/remote_data_source.dart';
import '../../../data/models/get_images_model.dart';
import 'package:http_parser/http_parser.dart';

class NewUploadImagesScreen extends StatefulWidget {
  final String gtin;
  const NewUploadImagesScreen({Key? key, required this.gtin}) : super(key: key);

  @override
  State<NewUploadImagesScreen> createState() => _NewUploadImagesScreenState();
}

class _NewUploadImagesScreenState extends State<NewUploadImagesScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  NewDatabaseHelper? databaseHelper;
  String longitudeData = "";
  String latitudeData = "";
  String imei = "";
  late UploadImagesProvider uploadImagesProvider;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(AppPreferences.getValueShared("uploadScreenCoach")==null||!AppPreferences.getValueShared("uploadScreenCoach")){
        UploadCoach.createTutorial();
        Future.delayed(Duration(milliseconds: 500), (){UploadCoach.showTutorial(context);});
        AppPreferences.addSharedPreferences(true,"uploadScreenCoach");
      }
    });



    AppPreferences.init();
    _tabController = TabController(length: 8, vsync: this);
    databaseHelper = NewDatabaseHelper();

    uploadImagesProvider =
        Provider.of<UploadImagesProvider>(context, listen: false);

    Utils.determinePosition().then((currentPosition) {
      longitudeData = "${currentPosition.longitude}";
      latitudeData = "${currentPosition.latitude}";
    });

    getDeviceImei();

  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};

  Future<void> getDeviceImei() async {
    try {
      if (Platform.isAndroid) {
        deviceData =
            Utils.readAndroidBuildData(await deviceInfoPlugin.androidInfo);

        print('The imei no is ${deviceData['androidId']}');

        imei = deviceData['androidId'];
        print('The Android device imei is $imei');
      } else {
        deviceData = Utils.readIosDeviceInfo(await deviceInfoPlugin.iosInfo);

        imei = deviceData['identifierForVendor'];
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Upload Images',),
            const Spacer(),
            Text(
              widget.gtin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 18,
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            //check if the image data is available
            if(VisibleProgressLoader.isShowing){
              VisibleProgressLoader.hide();
            }
            if (AppPreferences.getValueShared('isImageUploaded') ?? false) {
              //image is available
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Alert"),
                    content: Text("Your uploaded data will be lost."),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: Text("OK"),
                        onPressed: () async {
                          // Perform your desired action

                          ClickItConstants.reloadSharedPreference();

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewHomeScreen(isShowRatingDialog: false,),

                              ),
                                  (Route<dynamic> route) => false
                          );

                          //send the user to home screen
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewHomeScreen(isShowRatingDialog: false,),
                  ),(Route<dynamic> route) => false
              );
            }
          },
          icon: const Icon(CupertinoIcons.back),
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _buildTabBarView(),
            ),
          ),
          TabBar(
            labelPadding: EdgeInsets.only(right: 12,left: 12),
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            controller: _tabController,
            tabs: [
              Tab(text: 'Front'),
              Tab(text: 'Back'),
              Tab(text: 'Left'),
              Tab(text: 'Right'),
              Tab(text: 'Top'),
              Tab(text: 'Bottom'),
              Tab(text: 'Nutritional Table'),
              Tab(text: 'Ingredients'),
            ],
          ),
          SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: (){

              if(ClickItConstants.frontImageProcessing ||
                  ClickItConstants.backImageProcessing ||
                  ClickItConstants.topImageProcessing ||
                  ClickItConstants.bottomImageProcessing||
                  ClickItConstants.rightImageProcessing||
                  ClickItConstants.leftImageProcessing||
                  ClickItConstants.nutrientsImageProcessing||
                  ClickItConstants.ingredientImageProcessing){

                Fluttertoast.showToast(
                  msg: 'Please wait for finish processing',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );

              }
              else if(!AppPreferences.getValueShared(ClickItConstants.frontImageUploadedKey) &&
                  !AppPreferences.getValueShared(ClickItConstants.backImageUploadedKey) &&
                  !AppPreferences.getValueShared(ClickItConstants.topImageUploadedKey) &&
                  !AppPreferences.getValueShared(ClickItConstants.bottomImageUploadedKey)&&
                  !AppPreferences.getValueShared(ClickItConstants.rightImageUploadedKey)&&
                  !AppPreferences.getValueShared(ClickItConstants.leftImageUploadedKey)&&
                  !AppPreferences.getValueShared(ClickItConstants.nutrientsUploadedImageKey)&&
                  !AppPreferences.getValueShared(ClickItConstants.ingredientImageUploadedKey)){
                Fluttertoast.showToast(
                  msg: 'click at least one product image',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }else if(latitudeData==""&&longitudeData==""){
                Fluttertoast.showToast(
                  msg: 'Location is mandatory to upload',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Utils.determinePosition().then((currentPosition) {
                  longitudeData = "${currentPosition.longitude}";
                  latitudeData = "${currentPosition.latitude}";
                });

             }
              else{
                showDialog(
                    context: context,
                    builder: (context) {
                      if(AppPreferences.getValueShared("saveScreenCoach")==null||!AppPreferences.getValueShared("saveScreenCoach")){
                        SaveDataCoach.createTutorial();
                        Future.delayed(Duration.zero, (){SaveDataCoach.showTutorial(context);});
                        AppPreferences.addSharedPreferences(true,"saveScreenCoach");
                      }

                      return AlertDialog(
                        content: const Text('Where you want to store these images.'),
                        actions: [
                          ElevatedButton(
                            key:SaveDataCoach.localKey,
                            onPressed: () async {
                              Navigator.of(context).pop();
                              uploadImagesToLocalDatabase();
                            },
                            child: const Text('Local'),
                          ),
                          ElevatedButton(
                            key:SaveDataCoach.serverKey,
                            onPressed: () {
                              Navigator.of(context).pop();
                              uploadImagesToServer();

                            },
                            child: const Text('Server'),
                          ),
                        ],
                      );

                    }

                );
              }

            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              child:  Text(
                'Submit',
                key: UploadCoach.submitKey,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
              ),
            ),
          ),

        ],
      ),
    ),);
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: FrontImageScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: BackImageScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: LeftImageScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: RightImageScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: TopImageScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: BottomImageScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: NutritionalValueScreen(
            gtin: widget.gtin,
          ),
        ),
        ChangeNotifierProvider<UploadImagesProvider>.value(
          value: uploadImagesProvider,
          child: IngredientsValueScreen(
            gtin: widget.gtin,
          ),
        ),
      ],
    );
  }


  Future<bool> _onBackPressed() async{
    if(VisibleProgressLoader.isShowing){
      VisibleProgressLoader.hide();
    }
    if (AppPreferences.getValueShared('isImageUploaded') ?? false) {
      //image is available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text("Your uploaded data will be lost."),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text("OK"),
                onPressed: () async {
                  // Perform your desired action

                  await ClickItConstants.reloadSharedPreference();

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewHomeScreen(isShowRatingDialog: false,),
                      ),(Route<dynamic> route) => false
                  );

                  //send the user to home screen
                },
              ),
            ],
          );
        },
      );
      return false;
    } else {
      return true;
    }

  }

  void uploadImagesToServer() async{


    final front_image =
        await AppPreferences.getValueShared('front_image');
    final back_image =
        await AppPreferences.getValueShared('back_image');
    final left_image =
        await AppPreferences.getValueShared('left_image');
    final right_image =
        await AppPreferences.getValueShared('right_image');
    final top_image =
    await AppPreferences.getValueShared('top_image');
    final bottom_image =
    await AppPreferences.getValueShared('bottom_image');
    final nutrient_image =
    await AppPreferences.getValueShared('nutritional_value_image');
    final ingredient_image =
    await AppPreferences.getValueShared('ingredients_value_image');

    print(front_image);
    print(back_image);
    print(left_image);
    print(right_image);
    print(widget.gtin);
    print(AppPreferences.getValueShared('company_id'));

    /*if (!AppPreferences.getValueShared(ClickItConstants.frontImageUploadedKey) &&
        !AppPreferences.getValueShared(ClickItConstants.backImageUploadedKey) &&
        !AppPreferences.getValueShared(ClickItConstants.topImageUploadedKey) &&
        !AppPreferences.getValueShared(ClickItConstants.bottomImageUploadedKey)&&
        !AppPreferences.getValueShared(ClickItConstants.rightImageUploadedKey)&&
        !AppPreferences.getValueShared(ClickItConstants.leftImageUploadedKey)&&
        !AppPreferences.getValueShared(ClickItConstants.nutrientsUploadedImageKey)&&
        !AppPreferences.getValueShared(ClickItConstants.ingredientImageUploadedKey)
    ) {
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
      return;
    }*/

    /*if (front_image == null &&
        back_image == null &&
        left_image == null &&
        right_image == null&&
        top_image == null&&
        bottom_image == null&&
        nutrient_image == null&&
        ingredient_image == null
    ) {
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
      return;
    }*/



   // VisibleProgressLoader.show(context);

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
        'gtin': widget.gtin,
        'company_id':
        AppPreferences.getValueShared('source') == 'member'
            ? AppPreferences.getValueShared('company_id')
            : '',
        'uid':AppPreferences.getValueShared('uid').toString(),
        'source':AppPreferences.getValueShared('source'),
        'role_id':AppPreferences.getValueShared('role_id').toString(),
        'latitude' : latitudeData,
        'longitude' : longitudeData,
        'imei' : imei,
        'match' : 'true'

      });

      if(AppPreferences.getValueShared(ClickItConstants.frontImageUploadedKey)) {
        front_image == null ? request.fields.addAll({
          'img_front': '',
        })
            : request.files.add(await http.MultipartFile.fromPath('img_front',
            front_image));
      }

      if(AppPreferences.getValueShared(ClickItConstants.backImageUploadedKey)) {
        back_image == null ? request.fields.addAll({
          'img_back': '',
        })
            : request.files.add(await http.MultipartFile.fromPath('img_back',
            back_image));
      }

      if(AppPreferences.getValueShared(ClickItConstants.leftImageUploadedKey)) {
        left_image == null ? request.fields.addAll({
          'img_left': '',
        })
            : request.files.add(await http.MultipartFile.fromPath('img_left',
            left_image));
      }

      if(AppPreferences.getValueShared(ClickItConstants.rightImageUploadedKey)) {
        right_image == null ? request.fields.addAll({
          'img_right': '',
        })
            : request.files.add(await http.MultipartFile.fromPath('img_right',
            right_image));
      }

      if(AppPreferences.getValueShared(ClickItConstants.ingredientImageUploadedKey)) {
        ingredient_image == null
            ? request.fields.addAll({
          'ingredients_image': '',
        })
            : request.files.add(await http.MultipartFile.fromPath(
            'ingredients_image',
            ingredient_image ??
                ''));
      }

      if(AppPreferences.getValueShared(ClickItConstants.nutrientsUploadedImageKey)) {
        nutrient_image == null
            ? request.fields.addAll({
          'nutritional_image': '',
        })
            : request.files.add(await http.MultipartFile.fromPath(
            'nutritional_image',
            nutrient_image ??
                ''));
      }

      if(AppPreferences.getValueShared(ClickItConstants.topImageUploadedKey)) {
        top_image == null
            ? request.fields.addAll({
          'img_top': '',
        })
            : request.files.add(await http.MultipartFile.fromPath(
            'img_top',
            top_image ??
                ''));
      }

      if(AppPreferences.getValueShared(ClickItConstants.bottomImageUploadedKey)) {
        bottom_image == null
            ? request.fields.addAll({
          'img_bottom': '',
        })
            : request.files.add(await http.MultipartFile.fromPath(
            'img_bottom',
            bottom_image   ??
                ''));
      }
      EasyLoading.show(status: 'uploading...');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
    print(await response.stream.bytesToString());

   // VisibleProgressLoader.hide();
    EasyLoading.dismiss();
    //image uploaded successfully

    Fluttertoast.showToast(
    msg: 'Image Saved Successfully',
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
    );

    print('+++${AppPreferences.getValueShared('source')}');

    bool isShowRating =
    await AppPreferences.getValueShared('isShowRating') == null
        ? true : AppPreferences.getValueShared('isShowRating');

    await ClickItConstants.reloadSharedPreference();

    await NewDatabaseHelper().delete(widget.gtin);
    await NewDatabaseHelper().queryAllRows().then((value) async {
      print(value);
      if (value.length == 0) {
        print(value);
        await deleteAllLocallySavedFiles();
      }
    });

    ClickItConstants.isShowRatingOnce = isShowRating;

    Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
    builder: (context) => NewHomeScreen(isShowRatingDialog: isShowRating,),
    ),(Route<dynamic> route) => false);

    //send the user to home screen
    } else {
    print(response.reasonPhrase);
  //  VisibleProgressLoader.hide();
    EasyLoading.dismiss();
    Fluttertoast.showToast(
    msg: 'Please try again after some time');
    }
    } on Exception catch (e) {
    print(e.toString());
  //  VisibleProgressLoader.hide();
    EasyLoading.dismiss();
    Fluttertoast.showToast(msg: e.toString());
    }
  }

  void uploadImagesToLocalDatabase() async{
    //  save the images in Local database
    var front_image = null;
    var back_image = null;
    var left_image = null;
    var right_image = null;
    var top_image = null;
    var bottom_image = null;
    var nutritional_image = null;
    var ingredient_image = null;

    if(AppPreferences.getValueShared(ClickItConstants.frontImageUploadedKey)) {
      front_image =
      await AppPreferences.getValueShared('front_edited_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.backImageUploadedKey)) {
      back_image =
      await AppPreferences.getValueShared('back_edited_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.leftImageUploadedKey)) {
      left_image =
      await AppPreferences.getValueShared('left_edited_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.rightImageUploadedKey)) {
      right_image =
      await AppPreferences.getValueShared('right_edited_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.topImageUploadedKey)) {
      top_image =
      await AppPreferences.getValueShared('top_edited_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.bottomImageUploadedKey)) {
      bottom_image =
      await AppPreferences.getValueShared('bottom_edited_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.nutrientsUploadedImageKey)) {
      nutritional_image =
      await AppPreferences.getValueShared('nutritional_value_image');
    }
    if(AppPreferences.getValueShared(ClickItConstants.ingredientImageUploadedKey)) {
      ingredient_image =
      await AppPreferences.getValueShared('ingredients_value_image');
    }

   /* if (!AppPreferences.getValueShared(ClickItConstants.frontImageUploadedKey) &&
        !AppPreferences.getValueShared(ClickItConstants.backImageUploadedKey) &&
        !AppPreferences.getValueShared(ClickItConstants.topImageUploadedKey) &&
        !AppPreferences.getValueShared(ClickItConstants.bottomImageUploadedKey)&&
        !AppPreferences.getValueShared(ClickItConstants.rightImageUploadedKey)&&
        !AppPreferences.getValueShared(ClickItConstants.leftImageUploadedKey)&&
        !AppPreferences.getValueShared(ClickItConstants.nutrientsUploadedImageKey)&&
        !AppPreferences.getValueShared(ClickItConstants.ingredientImageUploadedKey)
    ) {
      Fluttertoast.showToast(
        msg: 'click at least one product image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }*/
      /*databaseHelper
          ?.queryAllRows()
          .then((value) => print(value));*/
 // else {
      final SharedPreferences _sharedPreferences =
      await SharedPreferences.getInstance();

      //insert into the database
      //row to insert
      Map<String, dynamic> row = {
        NewDatabaseHelper.GTIN: widget.gtin,
        NewDatabaseHelper.COMPANYID : AppPreferences.getValueShared('company_id'),
        NewDatabaseHelper.MATCH: "true",
        NewDatabaseHelper.LATITUDE: latitudeData,
        NewDatabaseHelper.LONGITUDE: longitudeData,
        NewDatabaseHelper.UID:
        AppPreferences.getValueShared('uid'),
        NewDatabaseHelper.ROLEID:
        AppPreferences.getValueShared('role_id').toString(),
        NewDatabaseHelper.IMEI: imei,
        NewDatabaseHelper.SOURCE:
        AppPreferences.getValueShared('source'),
        NewDatabaseHelper.FRONTIMAGE: front_image != null
            ?
        front_image
            : '',
        NewDatabaseHelper.BACKIMAGE: back_image != null
            ?
        back_image
            : '',
        NewDatabaseHelper.RIGHTIMAGE: left_image != null
            ?
        left_image
            : '',
        NewDatabaseHelper.LEFTIMAGE: right_image != null
            ?
        right_image
            : '',
        NewDatabaseHelper.TOPIMAGE: top_image != null
            ?
        top_image
            : '',
        NewDatabaseHelper.BOTTOMIMAGE: bottom_image != null
            ?
        bottom_image
            : '',
        NewDatabaseHelper.INGREDIENTSIMAGE: ingredient_image != null
            ?
        ingredient_image
            : '',
        NewDatabaseHelper.NUTRIENTSIMAGE: nutritional_image != null
            ?
        nutritional_image
            : '',

      };

      final id = await NewDatabaseHelper().insertOrUpdate(row).then(
            (value) async {

              bool isShowRating =
              await AppPreferences.getValueShared('isShowRating') == null
                  ? true : AppPreferences.getValueShared('isShowRating');

          ClickItConstants.reloadSharedPreference();

          Fluttertoast.showToast(
            msg: 'Image Saved Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
              ClickItConstants.isShowRatingOnce = isShowRating;
          //send the user to home screen
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewHomeScreen(isShowRatingDialog: isShowRating,),
              ), (Route<dynamic> route) => false);
        },
      );

      print('inserted row id: $id');

   // }
  }

  Future<void> deleteAllLocallySavedFiles() async{

    final directory = await getTemporaryDirectory();

    directory.deleteSync(recursive: true);
    
    directory.create();

  }

}
