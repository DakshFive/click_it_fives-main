import 'dart:io';

import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/get_images_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  final String gtin;
  const Upload({Key? key, required this.gtin}) : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? frontImage, backImage, leftImage, rightImage;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};
//static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  DatabaseHelper? databaseHelper;
  bool changeColor = true;

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

    getProductImages(widget.gtin);

    Utils.determinePosition().then((currentPosition) {
      if (currentPosition != null) {
        longitudeData = "${currentPosition.longitude}";
        latitudeData = "${currentPosition.latitude}";
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // **Original CArd
              Card(
                elevation: 4.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  height: 250,
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              // **OPen Camer Gallery
                            },
                            child: Text("Original",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Retake",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // **Edited CArd
              Card(
                elevation: 4.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  height: 270,
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {},
                            child: Text("Edited",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17)),
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: <Widget>[
                      //     Text("Resolution :"),
                      //     IconButton(
                      //         onPressed: () {},
                      //         icon: Icon(
                      //           Icons.delete,
                      //           color: Colors.red,
                      //         ))
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const SizedBox(
                      height: 37,
                      width: 300.0,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Resolution : High',
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 40,
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text("Front"),
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        backgroundColor:
                            changeColor ? Colors.grey : Colors.deepOrange,
                        onSurface: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Back"),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.deepOrange,
                        onSurface: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Left"),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.deepOrange,
                        onSurface: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Right"),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.deepOrange,
                        onSurface: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Nutrition Value"),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.deepOrange,
                        onSurface: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Ingredients"),
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        // backgroundColor: Colors.deepOrange,
                        onSurface: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Build the credit card widget
  Card _buildCreditCard(
      {required Color color,
      String cardNumber = "",
      String cardHolder = "",
      String cardExpiration = ""}) {
    return Card(
      elevation: 4.0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLogosBlock(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '$cardNumber',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontFamily: 'CourrierPrime'),
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: <Widget>[
            //     _buildDetailsBlock(
            //       label: 'Resolution',
            //       value: cardHolder,
            //     ),
            //     _buildDetailsBlock(
            //       label: 'Delete Image',
            //       value: cardExpiration,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // Build the top row containing logos
  Row _buildLogosBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(width: 3, color: Colors.black),
              ),
            ),
          ),
          child: Text('Original'),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(width: 3, color: Colors.black),
              ),
            ),
          ),
          child: Text('Retake'),
        )
      ],
    );
  }
}
