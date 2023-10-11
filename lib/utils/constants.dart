
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';

class ClickItConstants{

  static String frontImageUploadedKey = 'isFrontImageUploaded';
  static String backImageUploadedKey = 'isBackImageUploaded';
  static String leftImageUploadedKey = 'isLeftImageUploaded';
  static String rightImageUploadedKey = 'isRightImageUploaded';
  static String topImageUploadedKey = 'isTopImageUploaded';
  static String bottomImageUploadedKey = 'isBottomImageUploaded';
  static String ingredientImageUploadedKey = 'isIngredientImageUploaded';
  static String nutrientsUploadedImageKey = 'isNutritionImageUploaded';
  static String isShowProceedDialogKey = 'isShowProceedDialog';

  static bool frontImageProcessing = false;
  static bool backImageProcessing = false;
  static bool leftImageProcessing = false;
  static bool rightImageProcessing = false;
  static bool topImageProcessing = false;
  static bool bottomImageProcessing = false;
  static bool ingredientImageProcessing = false;
  static bool nutrientsImageProcessing = false;

  static bool isShowSavedSyncEasyLoading = false;
  static String appVersion = "1.0.1";
  static String appVersionIOS = "1.0.3";

  static String APIID = "df4a3e288e73d4e3d6e4a975a0c3212d";
  static String APIKEY = "440f00981a1cc3b1ce6a4c784a4b84ea";

  static bool showDialogProceed = false;

  static bool isDoneNewHomeCoach = false;

  static bool isShowRatingOnce = false;

  static reloadSharedPreference() async{
    bool isShowProceedDialog = false;

    String userName =
        await AppPreferences.getValueShared('company_id');
    String company_name =
        await AppPreferences.getValueShared('company_name');

    bool isShowRating =
        await AppPreferences.getValueShared('isShowRating') == null
        ? true : AppPreferences.getValueShared('isShowRating');

    dynamic retrievedData =
        await AppPreferences.getValueShared('login_data');

    var uid = AppPreferences.getValueShared('uid');

    String source = AppPreferences.getValueShared('source');

    var roleId = AppPreferences.getValueShared('role_id');

    bool homeScreenCoachDone = AppPreferences.getValueShared("homeScreenCoach") ?? false;
    bool uploadScreenCoachDone = AppPreferences.getValueShared("uploadScreenCoach") ?? false;
    bool saveScreenCoachDone = AppPreferences.getValueShared("saveScreenCoach") ?? false;

    if(AppPreferences.getValueShared(ClickItConstants.isShowProceedDialogKey)!=null){
       isShowProceedDialog =  AppPreferences.getValueShared(ClickItConstants.isShowProceedDialogKey);
    }


    AppPreferences.clearSharedPreferences();

    AppPreferences.addSharedPreferences(homeScreenCoachDone,"homeScreenCoach");
    AppPreferences.addSharedPreferences(uploadScreenCoachDone,"uploadScreenCoach");
    AppPreferences.addSharedPreferences(saveScreenCoachDone,"saveScreenCoach");

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

    AppPreferences.addSharedPreferences(
        retrievedData, 'login_data');
    AppPreferences.addSharedPreferences(false, "isShowTutorial");
    AppPreferences.addSharedPreferences(isShowRating,"isShowRating");
    AppPreferences.addSharedPreferences(
        isShowProceedDialog, isShowProceedDialogKey);
  }

  static Future<String?> saveCompressedImageToDevice(Uint8List? compressedImage) async{
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

  static showProceedDialog(BuildContext context){
    bool isChecked = false;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (ctx, stfSetState){
            return AlertDialog(
              title: Text('Info'),
              content:  Text(
                  'Background removal is in progress.Please feel free to proceed with additional images.',
                  textAlign: TextAlign.start,
                  style:  TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                  )
              ),
              actions: [
                Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      value: isChecked,
                      onChanged: (bool? value) {
                        stfSetState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    SizedBox(width: 10,),
                    Text('Don\'t show again?')
                  ],
                ),
                TextButton(onPressed: (){
                  if(isChecked) {
                    AppPreferences.addSharedPreferences(
                        true, isShowProceedDialogKey);
                  }
                  Navigator.pop(context);
                }, child: Text('Ok'))
              ],
            );
          });

        });
  }

  static String getImageSize(File file) {
    final size = ImageSizeGetter.getSize(FileInput(file));
    if (size.needRotate) {
      final width = size.height;
      final height = size.width;
      print('width = $width, height = $height');
    } else {
      print('width = ${size.width}, height = ${size.height}');
    }

    return ""+size.width.toString()+"x"+size.height.toString()+"";
  }

  static Future<String?> saveAndGetImagePath(String url) async{


    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.jpg').create();
    file.writeAsString(url);
    return file.path;
  }



}