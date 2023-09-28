
import 'package:click_it_app/preferences/app_preferences.dart';

class ClickItConstants{

  static String frontImageUploadedKey = 'isFrontImageUploaded';
  static String backImageUploadedKey = 'isBackImageUploaded';
  static String leftImageUploadedKey = 'isLeftImageUploaded';
  static String rightImageUploadedKey = 'isRightImageUploaded';
  static String topImageUploadedKey = 'isTopImageUploaded';
  static String bottomImageUploadedKey = 'isBottomImageUploaded';
  static String ingredientImageUploadedKey = 'isIngredientImageUploaded';
  static String nutrientsUploadedImageKey = 'isNutritionImageUploaded';

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

}