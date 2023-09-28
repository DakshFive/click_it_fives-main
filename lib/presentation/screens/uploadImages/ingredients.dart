import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:click_it_app/common/loader/progressLoader.dart';
import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/uploadImages/image_viewer.dart';
import 'package:click_it_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/data_sources/Local Datasource/new_database.dart';

class IngredientsValueScreen extends StatefulWidget {
  String? gtin;
  IngredientsValueScreen({Key? key, required this.gtin}) : super(key: key);

  @override
  State<IngredientsValueScreen> createState() => _IngredientsValueScreenState();
}

class _IngredientsValueScreenState extends State<IngredientsValueScreen>
    with AutomaticKeepAliveClientMixin<IngredientsValueScreen> {
  File? productImage;
  String? imageResolution;
  NewDatabaseHelper? databaseHelper;
  bool isImageProcessing = false;
  String? bckgroundRemovedImagePath;

  File? frontImageBackup;
  Uint8List? backgroundRemovedImageBackup;

  Future<Null> pickImage(
    String source,
  ) async {
    try {
      final imagePicked = await ImagePicker().pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 100,
      );

      //checking if the user has selected the image
      if (imagePicked == null) return;

      //user has selected the image
      final imageTemporary = File(imagePicked.path);

      //productImage = imageTemporary;
      productImage = null;

      imageResolution = null;
      Navigator.pop(context);

      productImage = await _cropImage(imageTemporary);
      setState(() {});
      ProgressLoader.show(context);

      isImageProcessing = true;
      try {
        imageResolution = await getImageResolution(productImage);
        //imageResolution = "Medium";
        if (imageResolution!.toLowerCase() == 'low') {
          isImageProcessing = false;
          ProgressLoader.hide();
          EasyLoading.showError(
              'Uploaded Image has Low Resolution.Please upload again');
          imageResolution = null;
          productImage = null;
          setState(() {});

          return;
        }

        if (imageResolution == null) {
          ProgressLoader.hide();
          isImageProcessing = false;
          EasyLoading.showError('Please upload again..!');

          imageResolution = null;
          productImage = null;
          setState(() {});
          return;
        }

        //save the data in shared preferences
        AppPreferences.addSharedPreferences(true, ClickItConstants.ingredientImageUploadedKey);
        AppPreferences.addSharedPreferences(true, 'isImageUploaded');
        AppPreferences.addSharedPreferences(widget.gtin!, 'gtin');
        AppPreferences.addSharedPreferences(
            productImage!.path, 'ingredients_value_image');
        AppPreferences.addSharedPreferences(
            imageResolution, 'ingredients_value_image_resolution');

        EasyLoading.dismiss();
        ProgressLoader.hide();
        isImageProcessing = false;
        setState(() {});
      } catch (e) {
        ProgressLoader.hide();
        isImageProcessing = false;
        EasyLoading.showError('Please   again..');
        imageResolution = null;
        productImage = null;
        setState(() {});
        return;
      }

      setState(() {});

      // _cropImage(imageTemporary);
    } on PlatformException catch (e) {
      //exception could occur if the user has not permitted for the picker
      EasyLoading.showError('Please pick image again...');

      print('Failed to pick image: $e');
    }
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    ProgressLoader.hide();
    super.dispose();
  }

  Future<dynamic> bottomsheetUploads(
    BuildContext context,
  ) {
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
                  onTap: () => pickImage('camera'),
                  title: const Text('Camera'),
                ),
                const Divider(
                  height: 1.0,
                ),
                ListTile(
                  onTap: () => pickImage('gallery'),
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

  @override
  void initState() {
    databaseHelper = NewDatabaseHelper();

//get the saved data

    //getSavedData();
    getLocalSavedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // **Original CArd

                GestureDetector(
                  onTap: () {
                    productImage != null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewProductImage(
                                      image: productImage!,
                                    )),
                          )
                        : bottomsheetUploads(
                            context,
                          );
                  },
                  child: Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Card(
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 5,
                          child: Container(
                            height: 400,
                            width: double.infinity,
                            child: productImage == null
                                ? Center(
                                    child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt_outlined,
                                          size: 48,
                                          color: Colors.deepOrangeAccent),
                                      Text(
                                        'Upload Image',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ))
                                : Image.file(
                                    productImage!,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        if (isImageProcessing)
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        Positioned(
                          top: 10,
                          left: 20,
                          child: TextButton(
                            onPressed: () {},
                            child: Text("Original",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                            ),
                          ),
                        ),
                        productImage != null
                            ? Positioned(
                                top: 10,
                                right: 20,
                                child: Visibility(
                                  // ** make it true on resoliution low and med
                                  visible: true,
                                  child: TextButton(
                                    onPressed: () {
                                      bottomsheetUploads(
                                        context,
                                      );
                                    },
                                    child: Text("Retake",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 5,
                ),
                imageResolution != null
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.70,
                              padding: EdgeInsets.all(5),
                              child:
                                  Text('Resolution : ${imageResolution ?? ''}'),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                productImage = null;
                                imageResolution = null;
                                AppPreferences.addSharedPreferences(
                                    false, 'isImageUploaded');

                                AppPreferences.addSharedPreferences(
                                    widget.gtin, 'gtin');
                                AppPreferences.addSharedPreferences(
                                    '', 'ingredients_value_image');
                                AppPreferences.addSharedPreferences(
                                    '', 'ingredients_value_edited_image');
                                AppPreferences.addSharedPreferences(
                                    '', 'ingredients_value_image_resolution');

                                print(AppPreferences.getValueShared(
                                    'ingredients_value_image'));
                                print(AppPreferences.getValueShared(
                                    'ingredients_value_edited_image'));
                                productImage = frontImageBackup;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 40,
                              ),
                            )
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void getSavedData() async {
    await AppPreferences.init();

    print('getting the saved data');

    //get the saved front image from the api

    var headers = {
      'Content-Type': 'application/json',
      'Cookie':
          'ApplicationGatewayAffinity=2f967101da599eb0bb564bd1ae6b3983; ApplicationGatewayAffinityCORS=2f967101da599eb0bb564bd1ae6b3983; PHPSESSID=va59iiu58ls2f7l01fmoeng645'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://gs1datakart.org/api/v501/product_images?apiId=df4a3e288e73d4e3d6e4a975a0c3212d&apiKey=440f00981a1cc3b1ce6a4c784a4b84ea'));
    request.body = json.encode({"gtin": widget.gtin});
    request.headers.addAll(headers);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('++');
      String ingredientsImage = jsonDecode(
          await response.stream.bytesToString())['image_ingredients'];
      print(ingredientsImage);
      if (ingredientsImage == '') {
        //check the local database
        await getLocalSavedData();
      } else {
        // save the image to local path only if the product image is not available

        // check the product image first

        final productImagePath =
            await AppPreferences.getValueShared('ingredients_value_image') == ''
                ? null
                : AppPreferences.getValueShared('ingredients_value_image');

        print('===$productImagePath');
        productImage = productImagePath == null ? null : File(productImagePath);

        if (productImage == null) {
          String? imagePath = await _saveImageToDevice(ingredientsImage);

          await AppPreferences.addSharedPreferences(
              imagePath, 'ingredients_value_image');

          await getLocalSavedData();
        }
      }
    } else {
      print(response.reasonPhrase);
      await getLocalSavedData();
    }

    setState(() {});
  }

  Future<String?> _saveImageToDevice(String? imageUrl) async {
    Random random = Random();
    int randomNumber = random.nextInt(10000);
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${randomNumber}.png';

    final File imageFile = File(imagePath);
    if (imageUrl != null) {
      // Download the image from the provided URL and save it to the device
      final http.Response response = await http.get(Uri.parse(imageUrl));
      await imageFile.writeAsBytes(response.bodyBytes);
    }
    return imageFile.path;
  }

  Future<void> getLocalSavedData() async {
    final productImagePath =
        await AppPreferences.getValueShared('ingredients_value_image') == ''
            ? null
            : AppPreferences.getValueShared('ingredients_value_image');

    print('===$productImagePath');
    productImage = productImagePath == null ? null : File(productImagePath);
    frontImageBackup = productImagePath == null ? null : File(productImagePath);
    imageResolution = AppPreferences.getValueShared(
                'ingredients_value_image_resolution') ==
            ''
        ? null
        : AppPreferences.getValueShared('ingredients_value_image_resolution');

    setState(() {});
  }
}

Future<String?> getImageResolution(File? productImage) async {
  try {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://20.204.169.52:8090/backgroundRemovalScore'));
    request.files
        .add(await http.MultipartFile.fromPath('score', productImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String jsonData = await response.stream.bytesToString();
      jsonData = jsonDecode(jsonData)['quality'];
      return jsonData;
    } else {
      print(response.reasonPhrase);
      EasyLoading.showError(response.reasonPhrase.toString());
      return null;
    }
  } on Exception catch (e) {
    EasyLoading.showError(e.toString());
    return null;
  }
}

Future<File?> _cropImage(File? image) async {
  try {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: image!.path,
        compressQuality: 100,
        cropStyle: CropStyle.rectangle,
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
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Crop Image',
        ));

    return croppedFile;
  } on Exception catch (e) {
    Fluttertoast.showToast(msg: 'Failed To Crop Image');

    return null;
  }
}
