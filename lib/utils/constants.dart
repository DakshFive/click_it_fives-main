
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:click_it_app/preferences/app_preferences.dart';
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

  static String APIID = "df4a3e288e73d4e3d6e4a975a0c3212d";
  static String APIKEY = "440f00981a1cc3b1ce6a4c784a4b84ea";

  static reloadSharedPreference() async{
    String userName =
        await AppPreferences.getValueShared('company_id');
    String company_name =
        await AppPreferences.getValueShared('company_name');
    bool isImageUploaded =
        await AppPreferences.getValueShared('isImageUploaded');
    bool isShowRating =
        await AppPreferences.getValueShared('isShowRating') == null
        ? true : AppPreferences.getValueShared('isShowRating');
    String userRole =
        await AppPreferences.getValueShared('login_data');

    dynamic retrievedData =
        await AppPreferences.getValueShared('login_data');

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
    AppPreferences.addSharedPreferences(isShowRating,"isShowRating");
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

}