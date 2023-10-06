import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/common/loader/progressLoader.dart';
import 'package:click_it_app/controllers/upload_images_provider.dart';
import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/uploadImages/image_viewer.dart';
import 'package:click_it_app/utils/apis.dart';
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
import 'package:provider/provider.dart';
import '../../../app_tutorial_coach/tutorial_upload_coach.dart';
import '../../../common/loader/visible_progress_loaded.dart';
import '../../../data/data_sources/Local Datasource/new_database.dart';

class FrontImageScreen extends StatefulWidget {
  final String? gtin;
  FrontImageScreen({Key? key, required this.gtin}) : super(key: key);

  @override
  State<FrontImageScreen> createState() => _FrontImageScreenState();
}

class _FrontImageScreenState extends State<FrontImageScreen>
    with AutomaticKeepAliveClientMixin<FrontImageScreen> {
  File? productImage;
  File? editedSavedImage;
  String? imageResolution;
  Uint8List? backgroundRemovedImage;
  NewDatabaseHelper? databaseHelper;
  bool isImageProcessing = false;
  String? bckgroundRemovedImagePath;
  bool? isbarcodeScanned;
  File? frontImageBackup;
  Uint8List? backgroundRemovedImageBackup;
  Uint8List? compressedFrontImage;
  String? compressedFrontImagePath;
  String? resolutionText;

  Future<void> pickImage(
    String source,
  ) async {
    try {
      final XFile? imagePicked = await ImagePicker().pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 100,
      );

      // checking if the user has selected the image
      if (imagePicked == null) return;

      // user has selected the image
      final imageTemporary = File(imagePicked.path);

      // productImage = imageTemporary;
      productImage = null;
      editedSavedImage = null;
      backgroundRemovedImage = null;
      imageResolution = null;
      resolutionText = null;
      Navigator.pop(context);

      productImage = await _cropImage(imageTemporary);

      setState(() {});


      if(productImage==null){
        //ProgressLoader.hide();
        EasyLoading.showError('Please upload again..');
        return;
      }


     // ProgressLoader.getCircularProgressIndicator();
      isImageProcessing = true;
      ClickItConstants.frontImageProcessing = true;

      if(AppPreferences.getValueShared(ClickItConstants.isShowProceedDialogKey)==null ? true : !AppPreferences.getValueShared(ClickItConstants.isShowProceedDialogKey)){
        if(!ClickItConstants.showDialogProceed) {
          ClickItConstants.showProceedDialog(context);
          ClickItConstants.showDialogProceed = true;
        }
      }
      //ProgressLoader.show(context);
      compressedFrontImage = await ClickItApis.getCompressedImage(productImage!.path);
      if(compressedFrontImage!=null){
        compressedFrontImagePath = await _saveCompressedImageToDevice(compressedFrontImage);
      }else{
        //isImageProcessing = false;
        //ProgressLoader.hide();
        EasyLoading.showError('Please upload again..');
        setState(() {
          isImageProcessing = false;
          productImage = frontImageBackup;
        });
        return;
      }

        final compressImageFile = File(compressedFrontImagePath!);

        try {
          imageResolution = await getImageResolution(compressImageFile);
          resolutionText = ClickItConstants.getImageSize(compressImageFile);
          //imageResolution = "High";
          print('imageresolution is $imageResolution');
          if (imageResolution!.toLowerCase() == 'low') {
            isImageProcessing = false;
            ClickItConstants.frontImageProcessing = false;
            //ProgressLoader.hide();
            EasyLoading.showError(
                'Uploaded Image has Low Resolution.Please upload again');
            //    backgroundRemovedImage = null;
            imageResolution = null;
            resolutionText = null;
            if (AppPreferences.getValueShared('fetched_front_image') == '' ||
                AppPreferences.getValueShared('fetched_front_image') == null) {
              productImage = null;
            } else {
              productImage =
                  File(AppPreferences.getValueShared('fetched_front_image'));
              /*editedSavedImage =
                File(AppPreferences.getValueShared('fetched_front_image'));*/
            }
            setState(() {});
            return;
          }

          if (imageResolution == null) {
            //ProgressLoader.hide();
            isImageProcessing = false;
            ClickItConstants.frontImageProcessing = false;
            EasyLoading.showError('Please upload again..');
            backgroundRemovedImage = null;
            imageResolution = null;
            resolutionText = null;
            if (AppPreferences.getValueShared('fetched_front_image') == '' ||
                AppPreferences.getValueShared('fetched_front_image') == null) {
              productImage = null;
            } else {
              productImage =
                  File(AppPreferences.getValueShared('fetched_front_image'));
              /*editedSavedImage =
                File(AppPreferences.getValueShared('fetched_front_image'));*/
            }
            setState(() {});

            return;
          }
        } catch (e) {
          //ProgressLoader.hide();
          isImageProcessing = false;
          ClickItConstants.frontImageProcessing = false;
          EasyLoading.showError('Please upload again..');
          backgroundRemovedImage = null;
          imageResolution = null;
          resolutionText = null;
          if (AppPreferences.getValueShared('fetched_front_image') == '' ||
              AppPreferences.getValueShared('fetched_front_image') == null) {
            productImage = null;
          } else {
            productImage =
                File(AppPreferences.getValueShared('fetched_front_image'));
            /*editedSavedImage =
              File(AppPreferences.getValueShared('fetched_front_image'));*/
          }

          setState(() {});
          return;
        }



      setState(() {});

      try {
        backgroundRemovedImage = await removeImagebackground(compressImageFile);
        //backgroundRemovedImage = productImage!.readAsBytesSync();
        if (backgroundRemovedImage == null) {
          isImageProcessing = false;
          ClickItConstants.frontImageProcessing = false;
          EasyLoading.showError('Please upload again...');
          EasyLoading.dismiss();
          //ProgressLoader.hide();
          backgroundRemovedImage = null;
          imageResolution = null;
          resolutionText = null;
          productImage = frontImageBackup;
          setState(() {});
          return;
        }

        bckgroundRemovedImagePath =
            await _saveImageToDevice(backgroundRemovedImage);

        //save the data in shared preferences
        AppPreferences.addSharedPreferences(true, ClickItConstants.frontImageUploadedKey);
        AppPreferences.addSharedPreferences(true, 'isImageUploaded');
        AppPreferences.addSharedPreferences(widget.gtin!, 'gtin');
        AppPreferences.addSharedPreferences(productImage!.path, 'front_image');
        AppPreferences.addSharedPreferences(
            bckgroundRemovedImagePath!, 'front_edited_image');
        AppPreferences.addSharedPreferences(
            imageResolution, 'front_image_resolution');
        AppPreferences.addSharedPreferences(resolutionText, 'front_image_pixel');
        EasyLoading.dismiss();
        //ProgressLoader.hide();
        isImageProcessing = false;
        ClickItConstants.frontImageProcessing = false;
        setState(() {});
      } on Exception catch (e) {
        isImageProcessing = false;
        ClickItConstants.frontImageProcessing = false;
        EasyLoading.showError('Please upload again...');
        EasyLoading.dismiss();
        //ProgressLoader.hide();
        backgroundRemovedImage = null;
        imageResolution = null;
        resolutionText = null;
        productImage = frontImageBackup;
        setState(() {});
        return;
      }

    } on PlatformException catch (e) {
      setState(() {});
      //exception could occur if the user has not permitted for the picker
      EasyLoading.showError('Please pick image again...');
      //ProgressLoader.hide();
      print('Failed to pick image: $e');
    }
  }

  Future<File?> _cropImage(File? image) async {
    try {
      File? croppedFile = await ImageCropper().cropImage(
          sourcePath: image!.path,
          compressQuality: 90,
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

  @override
  void dispose() {
    EasyLoading.dismiss();
    //ProgressLoader.hide();
    super.dispose();
  }

  Future<String?> _saveImageToDevice(Uint8List? backgroundRemovedImage,
      {String? imageUrl}) async {
    if (backgroundRemovedImage != null || imageUrl != null) {
      Random random = Random();
      int randomNumber = random.nextInt(10000);
      final directory = await getTemporaryDirectory();

      final imagePath = '${directory.path}/${randomNumber}.png';

      final File imageFile = File(imagePath);

      if (backgroundRemovedImage != null) {
        // Save the provided Uint8List image to the device
        await imageFile.writeAsBytes(backgroundRemovedImage);
      } else if (imageUrl != null) {
        // Download the image from the provided URL and save it to the device
        final http.Response response = await http.get(Uri.parse(imageUrl));
        await imageFile.writeAsBytes(response.bodyBytes);
      }

      return imageFile.path;
    }
    return null;
  }

  Future<String?> _saveCompressedImageToDevice(Uint8List? compressedImage) async{
    if (compressedImage != null) {
      Random random = Random();
      int randomNumber = random.nextInt(10000);
      final directory = await getTemporaryDirectory();

      final imagePath = '${directory.path}/${randomNumber}.png';

      final File imageFile = File(imagePath);
        // Save the provided Uint8List image to the device
        await imageFile.writeAsBytes(compressedImage);

      return imageFile.path;
    }
    return null;
  }

  Future<dynamic> bottomsheetUploads(BuildContext context,)
  {
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
    isbarcodeScanned = AppPreferences.getValueShared('isImageUploaded');
    if(isbarcodeScanned==true){
      getLocalSavedData('front_image','front_edited_image','front_image_resolution');
    }else{
      //get the saved data
      getSavedData();

    }

    final uploadImagesProvider =
        Provider.of<UploadImagesProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // **Original Card

                GestureDetector(
                  onTap: () {
                    productImage != null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewProductImage(
                                image: productImage!,
                              ),
                            ),
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
                          key: UploadCoach.uploadKey,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 5,
                          child: Container(
                            height: 250,
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
                                    fit: BoxFit.scaleDown,
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

                /// background removed image
                Container(
                  width: double.infinity,
                  height: 250,
                  child: GestureDetector(
                    onTap: () {
                      editedSavedImage != null
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewProductImage(
                                        image: editedSavedImage,
                                      )),
                            )
                          : backgroundRemovedImage!=null
                      ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProductImage(
                                  image: backgroundRemovedImage,
                                ),
                              ),
                            )
                      :(){};
                    },
                    child: editedSavedImage != null
                        ? Stack(
                            children: [
                              Card(
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 5,
                                child: Container(
                                  height: 250,
                                  width: double.infinity,
                                  child: Image.file(
                                    editedSavedImage!,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 20,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text("Edited",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : backgroundRemovedImage != null
                            ? Stack(
                                children: [
                                  Card(
                                    margin: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 5,
                                    child: Container(
                                      height: 250,
                                      width: double.infinity,
                                      child:
                                          Image.memory(backgroundRemovedImage!,
                                          fit: BoxFit.scaleDown,
                                          ),

                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 20,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text("Edited",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                  ),
                ),

                SizedBox(
                  height: 5,
                ),
                resolutionText != null
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
                                  Text('Resolution : ${resolutionText ?? ''}'),
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
                                backgroundRemovedImage = null;
                                imageResolution = null;
                                resolutionText = null;
                                editedSavedImage = null;
                                AppPreferences.addSharedPreferences(
                                    false, 'isImageUploaded');

                                AppPreferences.addSharedPreferences(
                                    widget.gtin, 'gtin');
                                AppPreferences.addSharedPreferences(
                                    '', 'front_image');
                                AppPreferences.addSharedPreferences(
                                    '', 'front_edited_image');
                                AppPreferences.addSharedPreferences(
                                    '', 'front_image_resolution');
                                AppPreferences.addSharedPreferences(
                                    '', 'front_image_pixel');

                                AppPreferences.addSharedPreferences(false, ClickItConstants.frontImageUploadedKey);

                                print(AppPreferences.getValueShared(
                                    'front_image'));
                                print(AppPreferences.getValueShared(
                                    'front_edited_image'));

                                productImage = frontImageBackup;
                                //backgroundRemovedImage = frontImageBackup?.readAsBytesSync();
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
  bool get wantKeepAlive => true;

  void getSavedData() async {
    await AppPreferences.init();
    VisibleProgressLoader.show(context);
    print('getting the saved data');

    // get the saved front image from the api

    var headers = {
      'Content-Type': 'application/json',
      'Cookie':
          'ApplicationGatewayAffinity=2f967101da599eb0bb564bd1ae6b3983; ApplicationGatewayAffinityCORS=2f967101da599eb0bb564bd1ae6b3983; PHPSESSID=va59iiu58ls2f7l01fmoeng645'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://gs1datakart.org/api/v501/product_images?apiId=df4a3e288e73d4e3d6e4a975a0c3212d&apiKey=440f00981a1cc3b1ce6a4c784a4b84ea'));
    request.body = json.encode({"gtin": widget.gtin,"role_id":AppPreferences.getValueShared("role_id"),"upload_id":AppPreferences.getValueShared("uid")});
    request.headers.addAll(headers);
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print('++');
        final responseImageData = await response.stream.bytesToString();

        String frontImage = jsonDecode(responseImageData)['image_front'];
        print(frontImage);
        if (frontImage == '') {
          //check the local database
          await getLocalSavedData(
              'front_image', 'front_edited_image', 'front_image_resolution');
        } else {
          await saveToLocalAndShowImage(
              frontImage, 'front_image', 'front_edited_image',
              'fetched_front_image', 'front_image_resolution');
        }


        //save other image as well
        String backImage = jsonDecode(responseImageData)['image_back'];
        if (backImage == '') {
          await getLocalSavedDataOthers(
              'back_image', 'back_edited_image', 'back_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              backImage, 'back_image', 'back_edited_image',
              'fetched_back_image', 'back_image_resolution');
        }

        String leftImage =
        jsonDecode(responseImageData)['image_left'];
        if (leftImage == '') {
          await getLocalSavedDataOthers(
              'left_image', 'left_edited_image', 'left_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              leftImage, 'left_image', 'left_edited_image',
              'fetched_left_image', 'left_image_resolution');
        }

        String rightImage =
        jsonDecode(responseImageData)['image_right'];
        if (rightImage == '') {
          await getLocalSavedDataOthers(
              'right_image', 'right_edited_image', 'right_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              rightImage, 'right_image', 'right_edited_image',
              'fetched_right_image', 'right_image_resolution');
        }

        String topImage =
        jsonDecode(responseImageData)['image_top'];
        if (topImage == '') {
          await getLocalSavedDataOthers(
              'top_image', 'top_edited_image', 'top_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              topImage, 'top_image', 'top_edited_image', 'fetched_top_image',
              'top_image_resolution');
        }

        String bottomImage =
        jsonDecode(responseImageData)['image_bottom'];
        if (bottomImage == '') {
          await getLocalSavedDataOthers(
              'bottom_image', 'bottom_edited_image', 'bottom_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              bottomImage, 'bottom_image', 'bottom_edited_image',
              'fetched_bottom_image', 'bottom_image_resolution');
        }

        String nutritiousImage =
        jsonDecode(responseImageData)['image_nutritional'];
        if (nutritiousImage == '') {
          await getLocalSavedDataOthers(
              'nutritional_value_image', 'nutritional_value_edited_image',
              'nutritional_value_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              nutritiousImage, 'nutritional_value_image',
              'nutritional_value_edited_image',
              'fetched_nutritional_value_image',
              'nutritional_value_image_resolution');
        }

        String ingredientImage =
        jsonDecode(responseImageData)['image_ingredients'];
        if (ingredientImage == '') {
          await getLocalSavedDataOthers(
              'ingredients_value_image', 'ingredients_value_edited_image',
              'ingredients_value_image_resolution');
        } else {
          await saveToLocalAndShowImageOthers(
              ingredientImage, 'ingredients_value_image',
              'ingredients_value_edited_image',
              'fetched_ingredients_value_image',
              'ingredients_value_image_resolution');
        }
      } else {
        print(response.reasonPhrase);
        await getLocalSavedData(
            'front_image', 'front_edited_image', 'front_image_resolution');
        //setState(() {});
      }
    }catch(e){
      VisibleProgressLoader.hide();
    }
    VisibleProgressLoader.hide();
    setState(() {});
  }

  Future<void> saveToLocalAndShowImage(String serverImagePath,String imageType,String editedImageType,String fetchedImageType,String resolutionImageType) async{
    //save the image to local path only if the product image is not available

    //check the product image first

    final productImagePath =
    await AppPreferences.getValueShared(imageType) == ''
        ? null
        : AppPreferences.getValueShared(imageType);

    print('===$productImagePath');
    productImage = productImagePath == null ? null : File(productImagePath);
    final editedImagePath =
    await AppPreferences.getValueShared(editedImageType) == ''
        ? null
        : AppPreferences.getValueShared(editedImageType);

    /*editedSavedImage =
    editedImagePath == null ? null : File(editedImagePath);*/
    print('productImage  $productImage');

    //if (productImage == null) {
      print('product image is null');
      String? imagePath = await _saveImageToDevice(backgroundRemovedImage,
          imageUrl: serverImagePath);

      await AppPreferences.addSharedPreferences(imagePath,imageType);
      await AppPreferences.addSharedPreferences(
          imagePath, fetchedImageType);
      /*await AppPreferences.addSharedPreferences(
          imagePath, editedImageType);*/
      await getLocalSavedData(imageType,fetchedImageType,resolutionImageType);
   // }
    /*else if (editedImagePath == null) {
      print('editedSavedImage is null');
      String? imagePath = await _saveImageToDevice(backgroundRemovedImage,
          imageUrl: serverImagePath);

      await AppPreferences.addSharedPreferences(imagePath, imageType);
      await AppPreferences.addSharedPreferences(
          imagePath, fetchedImageType);
      await AppPreferences.addSharedPreferences(
          imagePath, editedImageType);
      await getLocalSavedData(imageType,editedImageType,resolutionImageType);
    }*/
  }

  Future<void> saveToLocalAndShowImageOthers(String serverImagePath,String imageType,String editedImageType,String fetchedImageType,String resolutionImageType) async{
    //save the image to local path only if the product image is not available

    //check the product image first

    final productImagePath =
    await AppPreferences.getValueShared(imageType) == ''
        ? null
        : AppPreferences.getValueShared(imageType);

    print('===$productImagePath');
    productImagePath == null ? null : File(productImagePath);
    //productImage = productImagePath == null ? null : File(productImagePath);
    final editedImagePath =
    await AppPreferences.getValueShared(editedImageType) == ''
        ? null
        : AppPreferences.getValueShared(editedImageType);

    editedImagePath == null ? null : File(editedImagePath);

   /* editedSavedImage =
    editedImagePath == null ? null : File(editedImagePath);*/
    print('productImage  $productImage');

    if (productImagePath == null) {
      print('product image is null');
      String? imagePath = await _saveImageToDevice(backgroundRemovedImage,
          imageUrl: serverImagePath);

      await AppPreferences.addSharedPreferences(imagePath,imageType);
      await AppPreferences.addSharedPreferences(
          imagePath, fetchedImageType);
      await AppPreferences.addSharedPreferences(
          imagePath, editedImageType);
      await getLocalSavedDataOthers(imageType,editedImageType,resolutionImageType);
    } /*else if (editedImagePath == null) {
      print('editedSavedImage is null');
      String? imagePath = await _saveImageToDevice(backgroundRemovedImage,
          imageUrl: serverImagePath);

      await AppPreferences.addSharedPreferences(imagePath, imageType);
      await AppPreferences.addSharedPreferences(
          imagePath, fetchedImageType);
      await AppPreferences.addSharedPreferences(
          imagePath, editedImageType);
      await getLocalSavedDataOthers(imageType,editedImageType,resolutionImageType);
    }*/
  }

  Future<void> getLocalSavedDataOthers(String imageType,String editedImageType,String resolutionImageType) async {
    final productImagePath =
    await AppPreferences.getValueShared('$imageType') == ''
        ? null
        : AppPreferences.getValueShared('$imageType');

    print('===$productImagePath');
    //productImage = productImagePath == null ? null : File(productImagePath);
    //frontImageBackup = productImagePath == null ? null : File(productImagePath);
    final editedImagePath =
    await AppPreferences.getValueShared('$editedImageType') == ''
        ? null
        : AppPreferences.getValueShared('$editedImageType');

    //editedSavedImage = editedImagePath == null ? null : File(editedImagePath);

    print('editedSavedImage  is $editedSavedImage');
    /*imageResolution =
    AppPreferences.getValueShared('$resolutionImageType') == ''
        ? null
        : AppPreferences.getValueShared('$resolutionImageType');*/

  }


  Future<void> getLocalSavedData(String imageType,String editedImageType,String resolutionImageType) async {
    final productImagePath =
        await AppPreferences.getValueShared('$imageType') == ''
            ? null
            : AppPreferences.getValueShared('$imageType');

    print('===$productImagePath');
    productImage = productImagePath == null ? null : File(productImagePath);
    frontImageBackup = productImagePath == null ? null : File(productImagePath);

    final editedImagePath =
    await AppPreferences.getValueShared('$editedImageType') == ''
        ? null
        : AppPreferences.getValueShared('$editedImageType');


    print('editedSavedImage  is $editedSavedImage');
    imageResolution =
        AppPreferences.getValueShared('$resolutionImageType') == ''
            ? null
            : AppPreferences.getValueShared('$resolutionImageType');
    resolutionText =
    AppPreferences.getValueShared('front_image_pixel') == ''
        ? null
        : AppPreferences.getValueShared('front_image_pixel');


    if(imageResolution!=null)
      editedSavedImage = editedImagePath == null ? null : File(editedImagePath);
    setState(() {});

  }
}

Future<Uint8List?> removeImagebackground(File? productImage) async {
  try {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://20.204.169.52:8090/backgroundRemoval'));
    request.files
        .add(await http.MultipartFile.fromPath('image', productImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      print(response.reasonPhrase);
      EasyLoading.showError(response.reasonPhrase.toString());
      return null;
    }
  } on Exception catch (e) {
    EasyLoading.showError(e.toString());
  }
  return null;
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

Future<Uint8List?> getCompressedImage(File? productImage) async {
  try {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://4.240.61.161:4002/compress'));
    request.files
        .add(await http.MultipartFile.fromPath('image', productImage!.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
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
