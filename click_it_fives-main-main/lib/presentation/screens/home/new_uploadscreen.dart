// import 'dart:convert';
// import 'dart:io';

// import 'dart:typed_data';
// import 'package:click_it_app/common/Utils.dart';
// import 'package:click_it_app/common/utility.dart';
// import 'package:click_it_app/data/core/apiClient.dart';

// import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
// import 'package:click_it_app/data/data_sources/remote_data_source.dart';
// import 'package:click_it_app/data/models/get_images_model.dart';

// import 'package:click_it_app/data/models/quality_model.dart';
// import 'package:click_it_app/data/models/upload_images_model.dart';
// import 'package:click_it_app/presentation/screens/home/backImage_screen.dart';
// import 'package:click_it_app/presentation/screens/home/home_screen.dart';
// import 'package:click_it_app/presentation/screens/home/show_image.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';

// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';

// import 'package:http/http.dart' as http;
// import 'package:rflutter_alert/rflutter_alert.dart';

// class UploadImagesScreen extends StatefulWidget {
//   final String gtin;
//   const UploadImagesScreen({Key? key, required this.gtin}) : super(key: key);

//   @override
//   State<UploadImagesScreen> createState() => _UploadImagesScreenState();
// }

// class _UploadImagesScreenState extends State<UploadImagesScreen> {
//   File? frontImage, backImage, leftImage, rightImage;
//   static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   var deviceData = <String, dynamic>{};
// //static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   Map<String, dynamic> _deviceData = <String, dynamic>{};
//   DatabaseHelper? databaseHelper;

//   String longitudeData = "";
//   String latitudeData = "";
//   String imei = "";

//   //already available product images

//   String? productFrontImage,
//       productBackImage,
//       productLeftImage,
//       productRightImage;

//   var globalcheck = "";
//   String qualityCheckUrl = "http://20.204.169.52:8080/get-score/front";

//   // **Loader
//   bool _loading = false;
//   bool retakeBtnEnable = true;
//   bool submitBtnActive = false;

//   bool showProgressBar = false;

//   List<bool> _selections = List.generate(8, (index) => false);

//   Uint8List? frontImageFile, backImageFile, rightImageFile;

//   String? imagePath;

//   _onLoading() {
//     setState(() {
//       showDialog(
//           context: context,
//           builder: (context) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: Colors.deepOrange,
//               ),
//             );
//           });
//     });
//   }

//   // / ** Quality Check APi Fucntion
//   Future<void> checkQuality() async {
//     try {
//       if (frontImage != null) {
//         SanityCheck qc = SanityCheck();

//         print('Enter');
//         var stream = new http.ByteStream(frontImage!.openRead());
//         stream.cast();

//         var length = await frontImage!.length();
//         var uri = Uri.parse(qualityCheckUrl);

//         var request = new http.MultipartRequest('POST', uri);

//         request.files
//             .add(await http.MultipartFile.fromPath("front", frontImage!.path));

//         var response = await request.send();

//         var res = await http.Response.fromStream(response);

//         dynamic resData = json.decode(res.body);
//         qc = SanityCheck.fromJson(resData["sanity_check"]);
//         // Printing response body in resdata
//         print(resData['sanity_check']['front']);
//         globalcheck = resData['sanity_check']['front'];
//         print(response.statusCode);

//         if (response.statusCode == 200) if (qc.front == "High" ||
//             qc.front == "Medium") {
//           // **Show Loader && show remove background image
//           frontImageFile = await ApiClient().remo(imagePath!);

//           Navigator.of(context).pop();

//           print('image uploaded');
//           print(globalcheck);
//           submitBtnActive = true;

//           setState(() {});
//         } else {
//           setState(() {
//             retakeBtnEnable = true;
//             submitBtnActive = false;
//             // TODO Disble Submt
//             Navigator.of(context).pop();
//           });

//           Alert(
//             context: context,
//             type: AlertType.error,
//             title: "RESOLUTION ALERT",
//             desc: "Please Upload High Quality Image.",
//             buttons: [],
//           ).show();

//           // **image Resolution Low show alert box

//           print('Image Resolition Low');
//         }
//         else {
//           print("Failed 400 code");
//         }
//       } else {
//         _onLoading();
//         print(' Please Upload Image');
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//       throw e;
//     }
//   }

//   Future<Null> pickImage(String source, String imageType) async {
//     try {
//       final imagePicked = await ImagePicker().pickImage(
//         source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
//       );

//       if (imagePicked != null) {
//         imagePath = imagePicked.path;
//         frontImageFile = await imagePicked.readAsBytes();
//         //user has selected the image
//         final imageTemporary = File(imagePicked.path);

//         _cropImage(imageTemporary, imageType);

//         setState(() {});
//       } else {
//         //checking if the user has selected the image
//         if (imagePicked == null) return;
//       }
//     } on PlatformException catch (e) {
//       frontImageFile = null;
//       setState(() {});
//       //exception could occur if the user has not permitted for the picker

//       print('Failed to pick image: $e');
//     }
//   }

//   Future<Null> _cropImage(File? image, String imageType) async {
//     File? croppedFile = await ImageCropper().cropImage(
//         sourcePath: image!.path,
//         maxWidth: 420,
//         maxHeight: 420,
//         aspectRatioPresets: Platform.isAndroid
//             ? [
//                 CropAspectRatioPreset.square,
//                 CropAspectRatioPreset.ratio3x2,
//                 CropAspectRatioPreset.original,
//                 CropAspectRatioPreset.ratio4x3,
//                 CropAspectRatioPreset.ratio16x9
//               ]
//             : [
//                 CropAspectRatioPreset.original,
//                 CropAspectRatioPreset.square,
//                 CropAspectRatioPreset.ratio3x2,
//                 CropAspectRatioPreset.ratio4x3,
//                 CropAspectRatioPreset.ratio5x3,
//                 CropAspectRatioPreset.ratio5x4,
//                 CropAspectRatioPreset.ratio7x5,
//                 CropAspectRatioPreset.ratio16x9
//               ],
//         androidUiSettings: const AndroidUiSettings(
//             toolbarTitle: 'Cropper',
//             toolbarColor: Colors.deepOrange,
//             toolbarWidgetColor: Colors.white,
//             initAspectRatio: CropAspectRatioPreset.original,
//             lockAspectRatio: false),
//         iosUiSettings: const IOSUiSettings(
//           title: 'Cropper',
//         ));

//     if (croppedFile != null) {
//       Navigator.pop(context, image);
//       setState(() {
//         Future.delayed(Duration(microseconds: 4));
//         _onLoading();

//         print('the current imagetype is $imageType');
//         if (imageType == 'frontImage') {
//           frontImage = croppedFile;
//           checkQuality();
//         } else if (imageType == 'backImage') {
//           backImage = croppedFile;

//           print(backImage);
//         } else if (imageType == 'leftImage') {
//           leftImage = croppedFile;
//         } else {
//           rightImage = croppedFile;
//         }
//       });
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     retakeBtnEnable = false;

//     getProductImages(widget.gtin);

//     Utils.determinePosition().then((currentPosition) {
//       if (currentPosition != null) {
//         longitudeData = "${currentPosition.longitude}";
//         latitudeData = "${currentPosition.latitude}";
//       }
//     });

//     databaseHelper = DatabaseHelper();
//   }

//   Future<void> initPlatformState() async {
//     var deviceData = <String, dynamic>{};

//     try {
//       if (Platform.isAndroid) {
//         deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
//       }
//     } on PlatformException {
//       deviceData = <String, dynamic>{
//         'Error:': 'Failed to get platform version.'
//       };
//     }

//     if (!mounted) return;

//     setState(() {
//       _deviceData = deviceData;
//     });
//   }

//   Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
//     return <String, dynamic>{
//       'version.securityPatch': build.version.securityPatch,
//       'version.sdkInt': build.version.sdkInt,
//       'version.release': build.version.release,
//       'version.previewSdkInt': build.version.previewSdkInt,
//       'version.incremental': build.version.incremental,
//       'version.codename': build.version.codename,
//       'version.baseOS': build.version.baseOS,
//       'board': build.board,
//       'bootloader': build.bootloader,
//       'brand': build.brand,
//       'device': build.device,
//       'display': build.display,
//       'fingerprint': build.fingerprint,
//       'hardware': build.hardware,
//       'host': build.host,
//       'id': build.id,
//       'manufacturer': build.manufacturer,
//       'model': build.model,
//       'product': build.product,
//       'supported32BitAbis': build.supported32BitAbis,
//       'supported64BitAbis': build.supported64BitAbis,
//       'supportedAbis': build.supportedAbis,
//       'tags': build.tags,
//       'type': build.type,
//       'isPhysicalDevice': build.isPhysicalDevice,
//       //'androidId': build.androidId,
//       'systemFeatures': build.systemFeatures,
//     };
//   }

//   Future<void> getDeviceImei() async {
//     try {
//       if (Platform.isAndroid) {
//         deviceData =
//             Utils.readAndroidBuildData(await deviceInfoPlugin.androidInfo);

//         print('The imei no is ${deviceData['androidId']}');

//         imei = deviceData['androidId'];
//         print('The Android device imei is $imei');
//       } else {
//         deviceData = Utils.readIosDeviceInfo(await deviceInfoPlugin.iosInfo);

//         imei = deviceData['identifierForVendor'];
//       }
//     } on PlatformException {
//       deviceData = <String, dynamic>{
//         'Error:': 'Failed to get platform version.'
//       };
//     }

//     if (!mounted) return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomSheet: Container(
//         width: MediaQuery.of(context).size.width,
//         height: kToolbarHeight,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(onSurface: Colors.deepOrange),
//           child: Text(
//             'Submit',
//             style: TextStyle(fontSize: 20),
//           ),
//           onPressed: submitBtnActive
//               ? () {
//                   // **Onsubmit Click

//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       content:
//                           const Text('Where you want to store these images.'),
//                       actions: [
//                         ElevatedButton(
//                           onPressed: () async {
//                             //  save the images in Local database

//                             if (frontImage != null ||
//                                 backImage != null ||
//                                 leftImage != null ||
//                                 rightImage != null) {
//                               //user has uploaded atleast one image

//                               print('user has not uploaded any new image');

//                               final SharedPreferences _sharedPreferences =
//                                   await SharedPreferences.getInstance();

//                               //insert into the database
//                               //row to insert
//                               Map<String, dynamic> row = {
//                                 DatabaseHelper.GTIN: widget.gtin,
//                                 DatabaseHelper.MATCH: "true",
//                                 DatabaseHelper.LATITUDE: latitudeData,
//                                 DatabaseHelper.LONGITUDE: longitudeData,
//                                 DatabaseHelper.UID:
//                                     _sharedPreferences.getString('uid')!,
//                                 DatabaseHelper.ROLEID: _sharedPreferences
//                                     .getInt('role_id')!
//                                     .toString(),
//                                 DatabaseHelper.IMEI: imei,
//                                 DatabaseHelper.SOURCE:
//                                     _sharedPreferences.getString('source')!,
//                                 DatabaseHelper.FRONTIMAGE: frontImage != null
//                                     ? Utility.base64String(
//                                         frontImage!.readAsBytesSync())
//                                     : '',
//                                 DatabaseHelper.BACKIMAGE: backImage != null
//                                     ? Utility.base64String(
//                                         backImage!.readAsBytesSync())
//                                     : '',
//                                 DatabaseHelper.RIGHTIMAGE: rightImage != null
//                                     ? Utility.base64String(
//                                         rightImage!.readAsBytesSync())
//                                     : '',
//                                 DatabaseHelper.LEFTIMAGE: leftImage != null
//                                     ? Utility.base64String(
//                                         leftImage!.readAsBytesSync())
//                                     : '',
//                               };

//                               final id = await databaseHelper?.insert(row).then(
//                                 (value) {
//                                   Fluttertoast.showToast(
//                                     msg: 'Image Saved Successfully',
//                                     toastLength: Toast.LENGTH_SHORT,
//                                     gravity: ToastGravity.CENTER,
//                                     timeInSecForIosWeb: 1,
//                                     backgroundColor: Colors.red,
//                                     textColor: Colors.white,
//                                     fontSize: 16.0,
//                                   );

//                                   //send the user to home screen

//                                   Navigator.push(
//                                     context,
//                                     PageTransition(
//                                       type: PageTransitionType.leftToRight,
//                                       child: HomeScreen(),
//                                     ),
//                                   );
//                                 },
//                               );

//                               print('inserted row id: $id');

//                               databaseHelper
//                                   ?.queryAllRows()
//                                   .then((value) => print(value));
//                             } else {
//                               Fluttertoast.showToast(
//                                 msg: 'Please upload atleast one product image',
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.CENTER,
//                                 timeInSecForIosWeb: 1,
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                                 fontSize: 16.0,
//                               );
//                             }
//                           },
//                           child: const Text('Local'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             //upload the images to the database

//                             uploadImages(context);

//                             // Navigator.push(
//                             //   context,
//                             //   PageTransition(
//                             //     type: PageTransitionType.leftToRight,
//                             //     child: HomeScreen(),
//                             //   ),
//                             // );
//                           },
//                           child: const Text('Server'),
//                         ),
//                       ],
//                     ),
//                   );
//                   child:
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(15),
//                     alignment: Alignment.center,
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                       ),
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Colors.deepOrange,
//                     ),
//                   );
// //
//                 }
//               : null,
//         ),
//       ),
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Text('Upload Images'),
//             const Spacer(),
//             Text(
//               widget.gtin,
//               style: const TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//         titleTextStyle: const TextStyle(
//           fontStyle: FontStyle.normal,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           fontSize: 14,
//         ),
//         elevation: 0,
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // **Original CArd
//             frontImage != null
//                 ? Card(
//                     margin: const EdgeInsets.all(10),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                     clipBehavior: Clip.antiAliasWithSaveLayer,
//                     elevation: 5,
//                     child: Container(
//                       height: 250,
//                       padding: const EdgeInsets.only(
//                           left: 16.0, right: 16.0, bottom: 15.0),
//                       decoration: BoxDecoration(
//                         // TODO ADD  Image File Image
//                         image: DecorationImage(
//                           image: FileImage(frontImage!),
//                           fit: BoxFit.cover,

//                           // fit: BoxFit.fill,
//                           alignment: Alignment.center,
//                         ),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           TextButton(
//                             onPressed: () {
//                               // **OPen Camer Gallery
//                               productFrontImage != null
//                                   ? bottomsheetShow(
//                                       context, productFrontImage!, 'frontImage')
//                                   : bottomsheetUploads(context, 'frontImage');
//                             },
//                             child: Text("Original",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 15)),
//                             style: TextButton.styleFrom(
//                               primary: Colors.white,
//                               backgroundColor: Colors.black,
//                             ),
//                           ),
//                           Visibility(
//                             // ** make it true on resoliution low and med
//                             visible: retakeBtnEnable,
//                             child: TextButton(
//                               onPressed: () {
//                                 // productFrontImage != null
//                                 productFrontImage != null
//                                     ? bottomsheetShow(context,
//                                         productFrontImage!, 'frontImage')
//                                     : bottomsheetUploads(context, 'frontImage');
//                               },
//                               child: Text("Retake",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15)),
//                               style: TextButton.styleFrom(
//                                 primary: Colors.white,
//                                 backgroundColor: Colors.deepOrange,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 // **Network Image For ORg Image
//                 : GestureDetector(
//                     onTap: () {
//                       // TODO
//                       productFrontImage != null
//                           ? bottomsheetShow(
//                               context, productFrontImage!, 'frontImage')
//                           : bottomsheetUploads(context, 'frontImage');
//                     },
//                     child: Card(
//                       margin: const EdgeInsets.all(10),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       clipBehavior: Clip.antiAliasWithSaveLayer,
//                       elevation: 5,
//                       child: Container(
//                         height: 250,
//                         padding: const EdgeInsets.only(
//                             left: 16.0, right: 16.0, bottom: 15.0),
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image: AssetImage(
//                                 "assets/images/addRm.png",
//                               ),
//                               alignment: Alignment.center,
//                               scale: 7),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             TextButton(
//                               onPressed: () {
//                                 // **OPen Camer Gallery
//                                 productFrontImage != null
//                                     ? bottomsheetShow(context,
//                                         productFrontImage!, 'frontImage')
//                                     : bottomsheetUploads(context, 'frontImage');
//                               },
//                               child: Text("Original",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15)),
//                               style: TextButton.styleFrom(
//                                 primary: Colors.white,
//                                 backgroundColor: Colors.black,
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 productFrontImage != null
//                                     ? bottomsheetShow(context,
//                                         productFrontImage!, 'frontImage')
//                                     : bottomsheetUploads(context, 'frontImage');
//                               },
//                               child: Text("Retake",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15)),
//                               style: TextButton.styleFrom(
//                                 primary: Colors.white,
//                                 backgroundColor: Colors.deepOrange,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//             // **Edited Image CArd

//             GestureDetector(
//               onTap: () {},
//               child: frontImage != null
//                   ? Card(
//                       elevation: 4.0,
//                       color: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Container(
//                         height: 270,
//                         padding: const EdgeInsets.only(
//                             left: 16.0, right: 16.0, bottom: 15.0),
//                         decoration: BoxDecoration(
//                           // TODO ADD  Image File Image
//                           image: DecorationImage(
//                             image: MemoryImage(frontImageFile!),
//                             fit: BoxFit.cover,

//                             // fit: BoxFit.fill,
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 TextButton(
//                                   onPressed: () {
//                                     // **Open Camera/gallery
//                                   },
//                                   child: Text("Edited Image",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 17)),
//                                   style: TextButton.styleFrom(
//                                     primary: Colors.white,
//                                     backgroundColor: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : GestureDetector(
//                       onTap: () {
//                         productFrontImage != null
//                             ? bottomsheetShow(
//                                 context, productFrontImage!, 'frontImage')
//                             : bottomsheetUploads(context, 'frontImage');
//                       },
//                       child: Card(
//                         margin: const EdgeInsets.all(10),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         clipBehavior: Clip.antiAliasWithSaveLayer,
//                         elevation: 5,
//                         child: Container(
//                           height: 250,
//                           padding: const EdgeInsets.only(
//                               left: 16.0, right: 16.0, bottom: 15.0),
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: AssetImage("assets/images/addRm.png"),
//                               // fit: BoxFit.fill,
//                               scale: 7,
//                               alignment: Alignment.center,
//                             ),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: <Widget>[
//                               TextButton(
//                                 onPressed: () {
//                                   //  **Remove Background of original image and view here
//                                   productFrontImage != null
//                                       ? bottomsheetShow(context,
//                                           productFrontImage!, 'frontImage')
//                                       : bottomsheetUploads(
//                                           context, 'frontImage');
//                                 },
//                                 child: Text("Edited",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 15)),
//                                 style: TextButton.styleFrom(
//                                   primary: Colors.white,
//                                   backgroundColor: Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     height: 37,
//                     width: 300.0,
//                     child: TextField(
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         labelText: 'Resolution : ${globalcheck}',
//                       ),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       submitBtnActive = false;
//                       globalcheck = "";
//                       frontImage = null;
//                     });
//                   },
//                   child: Icon(
//                     Icons.delete,
//                     color: Colors.red,
//                     size: 40,
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             // Toggle Btn Check Test
//             // SingleChildScrollView(
//             //   scrollDirection: Axis.horizontal,
//             //   child: Row(
//             //     children: [
//             //       ToggleButtons(
//             //         children: [
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: GestureDetector(
//             //                 onTap: () {
//             //                   Navigator.of(context).pushReplacement(
//             //                       new MaterialPageRoute(
//             //                           builder: (BuildContext context) {
//             //                     return new BackImageScreen(
//             //                       gtin: '',
//             //                     );
//             //                   }));
//             //                 },
//             //                 child: Text("Front")),
//             //           ),
//             //           GestureDetector(
//             //             onTap: () {
//             //               Navigator.of(context).pushReplacement(
//             //                   new MaterialPageRoute(
//             //                       builder: (BuildContext context) {
//             //                 return new BackImageScreen(
//             //                   gtin: '',
//             //                 );
//             //               }));
//             //             },
//             //             child: Padding(
//             //               padding: const EdgeInsets.all(18.0),
//             //               child: Text("back"),
//             //             ),
//             //           ),
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: Text("right"),
//             //           ),
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: Text("left"),
//             //           ),
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: Text("top"),
//             //           ),
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: Text("bottom"),
//             //           ),
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: Text("nutrioton val"),
//             //           ),
//             //           Padding(
//             //             padding: const EdgeInsets.all(8.0),
//             //             child: Text("Ingredients"),
//             //           ),
//             //         ],
//             //         isSelected: _selections,
//             //         onPressed: (int index) {
//             //           setState(() {
//             //             _selections[index] = !_selections[index];
//             //           });
//             //         },
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       // **front Image screen
//                       Navigator.of(context).pushReplacement(
//                           new MaterialPageRoute(
//                               builder: (BuildContext context) {
//                         return new BackImageScreen(
//                           gtin: '',
//                         );
//                       }));
//                     },
//                     child: Text("Front"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       // **Back Image screen

//                       Navigator.of(context).pushReplacement(
//                           new MaterialPageRoute(
//                               builder: (BuildContext context) {
//                         return new BackImageScreen(
//                           gtin: '',
//                         );
//                       }));
//                     },
//                     child: Text("Back"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("Left"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("Right"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("Top"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("Bottom"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("Nutrition Value"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("Ingredients"),
//                     style: TextButton.styleFrom(
//                       primary: Colors.white,
//                       backgroundColor: Colors.deepOrange,
//                       onSurface: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<dynamic> bottomsheetUploads(BuildContext context, String imageType) {
//     print('the imageType in front image is $imageType');
//     return showCupertinoModalBottomSheet(
//       expand: false,
//       context: context,
//       backgroundColor: Colors.white,
//       transitionBackgroundColor: Colors.yellow,
//       builder: (context) {
//         return Material(
//           child: Container(
//             height: 200,
//             child: ListView(
//               padding: const EdgeInsets.all(10),
//               children: [
//                 ListTile(
//                   onTap: () => pickImage('camera', imageType),
//                   title: const Text('Camera'),
//                 ),
//                 const Divider(
//                   height: 1.0,
//                 ),
//                 ListTile(
//                   onTap: () => pickImage('gallery', imageType),
//                   title: const Text('Gallery'),
//                 ),
//                 const Divider(
//                   height: 2.0,
//                 ),
//                 ListTile(
//                   onTap: () => Navigator.pop(context),
//                   title: const Text('Cancel'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<dynamic> bottomsheetShow(
//       BuildContext context, String imageType, String currentImageType) {
//     return showCupertinoModalBottomSheet(
//       expand: false,
//       context: context,
//       backgroundColor: Colors.white,
//       transitionBackgroundColor: Colors.yellow,
//       builder: (context) {
//         return Material(
//           child: Container(
//             height: 200,
//             child: ListView(
//               padding: const EdgeInsets.all(10),
//               children: [
//                 ListTile(
//                   onTap: () => Navigator.push(
//                     context,
//                     PageTransition(
//                       type: PageTransitionType.rightToLeft,
//                       child: ShowImageScreeen(
//                         image: imageType,
//                       ),
//                     ),
//                   ),
//                   title: const Text('View'),
//                 ),
//                 const Divider(
//                   height: 1.0,
//                 ),
//                 ListTile(
//                   onTap: () {
//                     Navigator.pop(context);

//                     bottomsheetUploads(context, currentImageType);
//                   },
//                   title: const Text('New Upload'),
//                 ),
//                 const Divider(
//                   height: 2.0,
//                 ),
//                 ListTile(
//                   onTap: () => Navigator.pop(context),
//                   title: const Text('Cancel'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void getProductImages(String scanResult) {
//     print(scanResult);

//     GetImagesRequestModel requestModel =
//         GetImagesRequestModel(gtin: scanResult);

//     Client _client = Client();
//     RemoteDataSource dataSource = RemoteDataSourceImple(_client);

//     dataSource.getImages(requestModel).then((value) {
//       print('get images completed');

//       setState(() {
//         if (value.imageFront.isNotEmpty) {
//           productFrontImage = value.imageFront;
//         }
//         if (value.imageBack.isNotEmpty) {
//           productBackImage = value.imageBack;
//         }
//         if (value.imageLeft.isNotEmpty) {
//           productLeftImage = value.imageLeft;
//         }
//         if (value.imageRight.isNotEmpty) {
//           productRightImage = value.imageRight;
//         }
//       });
//     });
//   }

//   void uploadImages(BuildContext context) async {
//     EasyLoading.show(status: 'uploading...');

//     //upload images
//     //get the saved values from the local storage in shared preferences

//     final SharedPreferences _sharedPreferences =
//         await SharedPreferences.getInstance();
//     print(_sharedPreferences.getString('company_name'));
//     print(_sharedPreferences.getString('company_id'));
//     print(_sharedPreferences.getString('source'));
//     print(_sharedPreferences.getInt('role_id'));
//     print(_sharedPreferences.getString('uid'));

//     UploadImagesRequestModel requestModel = UploadImagesRequestModel(
//       uid: _sharedPreferences.getString('uid')!,
//       gtin: widget.gtin,
//       roleId: _sharedPreferences.getInt('role_id')!.toString(),
//       latitude: latitudeData,
//       longitude: longitudeData,
//       match: "true",
//       imei: imei,
//       source: _sharedPreferences.getString('source')!,
//       imgBack: backImage != null ? Utils.encodeImage(backImage) : '',
//       imgFront: frontImage != null ? Utils.encodeImage(frontImage) : '',
//       imgRight: rightImage != null ? Utils.encodeImage(rightImage) : '',
//       imgLeft: leftImage != null ? Utils.encodeImage(leftImage) : '',
//       //  companyId: ["${_sharedPreferences.getString('company_id')}"]
//     );

//     Client _client = Client();
//     RemoteDataSource dataSource = RemoteDataSourceImple(_client);

//     //  dataSource.uploadImages(requestModel);

//     dataSource.uploadImages(requestModel).then(
//       (value) {
//         //    _dialog.hide();

//         EasyLoading.showSuccess('Image Uploaded Successfully');
//         EasyLoading.dismiss();
//         // Fluttertoast.showToast(
//         //     msg: 'Image Uploaded Successfully',
//         //     toastLength: Toast.LENGTH_SHORT,
//         //     gravity: ToastGravity.CENTER,
//         //     timeInSecForIosWeb: 1,
//         //     backgroundColor: Colors.red,
//         //     textColor: Colors.white,
//         //     fontSize: 16.0);

//         //send the user to home screen

//         Navigator.push(
//           context,
//           PageTransition(
//             type: PageTransitionType.leftToRight,
//             child: HomeScreen(),
//           ),
//         );
//       },
//     ).catchError((error) {
//       EasyLoading.showError(error);

//       print('error in uploading images $error');

//       //    _dialog.hide();
//       //send the user to home screen

//       // Navigator.push(
//       //   context,
//       //   PageTransition(
//       //     type: PageTransitionType.leftToRight,
//       //     child: HomeScreen(),
//       //   ),
//       // );
//     });
//   }
// }
