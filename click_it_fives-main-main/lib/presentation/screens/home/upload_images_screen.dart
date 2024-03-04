import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/common/utility.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/db_handler.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/get_images_model.dart';
import 'package:click_it_app/data/models/local_sync_images_model.dart';
import 'package:click_it_app/data/models/photo.dart';
import 'package:click_it_app/data/models/upload_images_model.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/home/show_image.dart';
import 'package:click_it_app/presentation/screens/home/sync_server_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;

class UploadImagesScreen extends StatefulWidget {
  final String gtin;
  const UploadImagesScreen({Key? key, required this.gtin}) : super(key: key);

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  File? frontImage, backImage, leftImage, rightImage;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};
//static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  DatabaseHelper? databaseHelper;

  String longitudeData = "";
  String latitudeData = "";
  String imei = "";

  //already available product images

  String? productFrontImage,
      productBackImage,
      productLeftImage,
      productRightImage;

  Future<Null> pickImage(String source, String imageType) async {
    try {
      final imagePicked = await ImagePicker().pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      );

      //checking if the user has selected the image
      if (imagePicked == null) return;

      //user has selected the image
      final imageTemporary = File(imagePicked.path);

      _cropImage(imageTemporary, imageType);
      // ** api call resoltion

      var imageQualityUrl = "http://20.204.169.52:8080/get-score/front";
      var imageData = {"front": frontImage};
      var bodydata = jsonEncode(imageData);
      var urlParse = Uri.parse(imageQualityUrl);
      Response response = await http.post(
        urlParse,
        body: bodydata,
      );
      var datares = response.body;

      print(datares);
      if (response == 201) {
        print("Success checked Quality");
      } else {
        print("Bad Image");
      }
    } on PlatformException catch (e) {
      //exception could occur if the user has not permitted for the picker

      print('Failed to pick image: $e');
    }
  }

  Future<Null> _cropImage(File? image, String imageType) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: image!.path,
        maxWidth: 420,
        maxHeight: 420,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ));

    if (croppedFile != null) {
      // Uint8List imagebytes = await croppedFile.readAsBytes(); //convert to bytes
      // String base64string =
      //     base64.encode(imagebytes); //convert bytes to base64 string
      // print('the base64string is ${base64string}');

      Navigator.pop(context, image);
      setState(() {
        print('the current imagetype is $imageType');
        if (imageType == 'frontImage') {
          frontImage = croppedFile;
        } else if (imageType == 'backImage') {
          backImage = croppedFile;

          print(backImage);
        } else if (imageType == 'leftImage') {
          leftImage = croppedFile;
        } else {
          rightImage = croppedFile;
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // initPlatformState();

    //  _dbHelper = DBHelper();

    //get the current locations
    // _determinePosition();

    getProductImages(widget.gtin);

    // SharedPreferences _sharedPref = await SharedPreferences.getInstance();

    // _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  true,  );
    //  Utils.initPlatformState();
    //   getDeviceImei();
    // getCurrentLocation();

    Utils.determinePosition().then((currentPosition) {
      longitudeData = "${currentPosition.longitude}";
      latitudeData = "${currentPosition.latitude}";
    });

    databaseHelper = DatabaseHelper();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      //'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Upload Images'),
            const Spacer(),
            Text(
              widget.gtin,
              style: const TextStyle(
                color: Colors.white,
              ),
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
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: [
                  // front image

                  GestureDetector(
                    onTap: () => productFrontImage != null
                        ? bottomsheetShow(
                            context, productFrontImage!, 'frontImage')
                        : bottomsheetUploads(context, 'frontImage'),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: productFrontImage != null
                                  ? Container(
                                      child: Center(
                                        child: frontImage != null
                                            ? Image.file(
                                                frontImage!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                            : Image(
                                                image: NetworkImage(
                                                    productFrontImage!),
                                                fit: BoxFit.cover,
                                                height: double.infinity,
                                                width: double.infinity,
                                              ),
                                      ),
                                    )
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(12),
                                      child: Container(
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: frontImage != null
                                                ? Image.file(
                                                    frontImage!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  )
                                                : const SizedBox(),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Front Image'),
                          ],
                        ),
                        const Positioned(
                          right: 10,
                          top: 10,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //back image

                  GestureDetector(
                    onTap: () => productBackImage != null
                        ? bottomsheetShow(
                            context, productBackImage!, 'backImage')
                        : bottomsheetUploads(context, 'backImage'),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: productBackImage != null
                                  ? Container(
                                      child: backImage != null
                                          ? Image.file(
                                              backImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Image(
                                              image: NetworkImage(
                                                  productBackImage!),
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: double.infinity,
                                            ))
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(12),
                                      child: Container(
                                        child: Center(
                                          child: backImage != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.file(
                                                    backImage!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Back Image'),
                          ],
                        ),
                        const Positioned(
                          right: 10,
                          top: 10,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //left image
                  GestureDetector(
                    onTap: () => productLeftImage != null
                        ? bottomsheetShow(
                            context, productLeftImage!, 'leftImage')
                        : bottomsheetUploads(context, 'leftImage'),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: productLeftImage != null
                                  ? Container(
                                      child: leftImage != null
                                          ? Image.file(
                                              leftImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Image(
                                              image: NetworkImage(
                                                  productLeftImage!),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ))
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(12),
                                      child: Container(
                                        child: Center(
                                          child: leftImage != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: ClipRRect(
                                                    child: Image.file(
                                                      leftImage!,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Left Image'),
                          ],
                        ),
                        const Positioned(
                          right: 10,
                          top: 10,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //right image

                  GestureDetector(
                    onTap: () => productRightImage != null
                        ? bottomsheetShow(
                            context, productRightImage!, 'rightImage')
                        : bottomsheetUploads(context, 'rightImage'),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: productRightImage != null
                                  ? Container(
                                      child: rightImage != null
                                          ? Image.file(
                                              rightImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Image(
                                              image: NetworkImage(
                                                  productRightImage!),
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: double.infinity,
                                            ))
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(12),
                                      child: Container(
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: rightImage != null
                                                ? Image.file(
                                                    rightImage!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  )
                                                : const SizedBox(),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Right Image'),
                          ],
                        ),
                        const Positioned(
                          right: 10,
                          top: 10,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text('Where you want to store these images.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        //  save the images in Local database

                        if (frontImage != null ||
                            backImage != null ||
                            leftImage != null ||
                            rightImage != null) {
                          //user has uploaded atleast one image

                          print('user has not uploaded any new image');

                          final SharedPreferences _sharedPreferences =
                          await SharedPreferences.getInstance();

                          //insert into the database
                          //row to insert
                          Map<String, dynamic> row = {
                            DatabaseHelper.GTIN: widget.gtin,
                            DatabaseHelper.MATCH: "true",
                            DatabaseHelper.LATITUDE: latitudeData,
                            DatabaseHelper.LONGITUDE: longitudeData,
                            DatabaseHelper.UID:
                            _sharedPreferences.getString('uid')!,
                            DatabaseHelper.ROLEID:
                            _sharedPreferences.getInt('role_id')!.toString(),
                            DatabaseHelper.IMEI: imei,
                            DatabaseHelper.SOURCE:
                            _sharedPreferences.getString('source')!,
                            DatabaseHelper.FRONTIMAGE: frontImage != null
                                ? Utility.base64String(
                                frontImage!.readAsBytesSync())
                                : '',
                            DatabaseHelper.BACKIMAGE: backImage != null
                                ? Utility.base64String(
                                backImage!.readAsBytesSync())
                                : '',
                            DatabaseHelper.RIGHTIMAGE: rightImage != null
                                ? Utility.base64String(
                                rightImage!.readAsBytesSync())
                                : '',
                            DatabaseHelper.LEFTIMAGE: leftImage != null
                                ? Utility.base64String(
                                leftImage!.readAsBytesSync())
                                : '',
                          };

                          final id = await databaseHelper?.insert(row).then(
                                (value) {
                              Fluttertoast.showToast(
                                msg: 'Image Saved Successfully',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );

                              //send the user to home screen

                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: HomeScreen(isShowRatingDialog: false,),
                                ),
                              );
                            },
                          );

                          print('inserted row id: $id');

                          databaseHelper
                              ?.queryAllRows()
                              .then((value) => print(value));
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Please upload atleast one product image',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      },
                      child: const Text('Local'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        //upload the images to the database

                        uploadImages(context);

                        // Navigator.push(
                        //   context,
                        //   PageTransition(
                        //     type: PageTransitionType.leftToRight,
                        //     child: HomeScreen(),
                        //   ),
                        // );
                      },
                      child: const Text('Server'),
                    ),
                  ],
                );

              }

            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> bottomsheetUploads(BuildContext context, String imageType) {
    print('the imageType in front image is $imageType');
    return showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.white,
      transitionBackgroundColor: Colors.yellow,
      builder: (context) {
        return Material(
          child: Container(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ListTile(
                  onTap: () => pickImage('camera', imageType),
                  title: const Text('Camera'),
                ),
                const Divider(
                  height: 1.0,
                ),
                ListTile(
                  onTap: () => pickImage('gallery', imageType),
                  title: const Text('Gallery'),
                ),
                const Divider(
                  height: 2.0,
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  title: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> bottomsheetShow(
      BuildContext context, String imageType, String currentImageType) {
    return showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.white,
      transitionBackgroundColor: Colors.yellow,
      builder: (context) {
        return Material(
          child: Container(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ListTile(
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: ShowImageScreeen(
                        image: imageType,
                      ),
                    ),
                  ),
                  title: const Text('View'),
                ),
                const Divider(
                  height: 1.0,
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);

                    bottomsheetUploads(context, currentImageType);
                  },
                  title: const Text('New Upload'),
                ),
                const Divider(
                  height: 2.0,
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  title: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void getProductImages(String scanResult) {
    print(scanResult);

    GetImagesRequestModel requestModel =
        GetImagesRequestModel(gtin: scanResult);

    Client _client = Client();
    RemoteDataSource dataSource = RemoteDataSourceImple(_client);

    dataSource.getImages(requestModel).then((value) {
      print('get images completed');

      setState(() {
        if (value.imageFront.isNotEmpty) {
          productFrontImage = value.imageFront;
        }
        if (value.imageBack.isNotEmpty) {
          productBackImage = value.imageBack;
        }
        if (value.imageLeft.isNotEmpty) {
          productLeftImage = value.imageLeft;
        }
        if (value.imageRight.isNotEmpty) {
          productRightImage = value.imageRight;
        }
      });
    });
  }

  void uploadImages(BuildContext context) async {
    //     _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false,  );

    //     if (mounted==true) {

    // if (Platform.isIOS) {
    //       _dialog.show(message: '',type:SimpleFontelicoProgressDialogType.iphone ,backgroundColor: Colors.transparent,indicatorColor: Colors.deepOrange);

    // }else{

    //        _dialog.show(message: '',type:SimpleFontelicoProgressDialogType.phoenix ,backgroundColor: Colors.transparent,indicatorColor: Colors.deepOrange);

    // }
    //     }

    // LoadingIndicator(
    // indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
    // colors.xml: const [Colors.white],       /// Optional, The color collections
    // strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
    // backgroundColor: Colors.black,      /// Optional, Background of the widget
    // pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
    //   );

    EasyLoading.show(status: 'uploading...');

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
      uid: _sharedPreferences.getString('uid')!,
      gtin: widget.gtin,
      roleId: _sharedPreferences.getInt('role_id')!.toString(),
      latitude: latitudeData,
      longitude: longitudeData,
      match: "true",
      imei: imei,
      source: _sharedPreferences.getString('source')!,
      imgBack: backImage != null ? Utils.encodeImage(backImage) : '',
      imgFront: frontImage != null ? Utils.encodeImage(frontImage) : '',
      imgRight: rightImage != null ? Utils.encodeImage(rightImage) : '',
      imgLeft: leftImage != null ? Utils.encodeImage(leftImage) : '',
      //  companyId: ["${_sharedPreferences.getString('company_id')}"]
    );*/

    Client _client = Client();
    RemoteDataSource dataSource = RemoteDataSourceImple(_client);

    //  dataSource.uploadImages(requestModel);

    /*dataSource.uploadImages(requestModel).then(
      (value) {
        //    _dialog.hide();

        EasyLoading.showSuccess('Image Uploaded Successfully');
        EasyLoading.dismiss();
        // Fluttertoast.showToast(
        //     msg: 'Image Uploaded Successfully',
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);

        //send the user to home screen

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.leftToRight,
            child: HomeScreen(),
          ),
        );
      },
    ).catchError((error) {
      EasyLoading.showError(error);*/

     // print('error in uploading images $error');

      //    _dialog.hide();
      //send the user to home screen

      // Navigator.push(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.leftToRight,
      //     child: HomeScreen(),
      //   ),
      // );
   // });
  }
}
