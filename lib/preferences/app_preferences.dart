import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

 
class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();

  factory AppPreferences() {
    return _instance;
  }

  AppPreferences._internal();

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// ------------------ Clear Data from SharedPreference ------------------ ///
  static clearSharedPreferences() async {
    _preferences.clear();
  }

  /// ------------------ Reload data from SharedPreference ------------------ ///

  static reloadData() async {
    _preferences.reload();
  }

  /// ------------------ Add Value in SharedPreference with Any Type ------------------ ///

  static addSharedPreferences(dynamic value, String key) async {
    if (value is int)
      _preferences.setInt(key, value);
    else if (value is double)
      _preferences.setDouble(key, value);
    else if (value is bool)
      _preferences.setBool(key, value);
    else if (value is String)
      _preferences.setString(key, value);
    else if (value is List<String>) _preferences.setStringList(key, value);
  }

  /// ------------------ Get Value in SharedPreference ------------------ ///

  static dynamic getValueShared(String key) {
    return _preferences.get(key);
  }

  static dynamic getImagePath(String key) {
    return _preferences.getString(key);
  }


  /// ------------------ Get Value in SharedPreference in list form------------------ ///

  static dynamic getValueSharedinList(String key) {
    return _preferences.getStringList(key);
  }

  // //use for login or not
  // static void setSignIn(bool val) {
  //   _preferences.setBool(AppKeys.isLogin, val);
  // }

  // static bool? getSignIn() {
  //   return _preferences.getBool(AppKeys.isLogin);
  // }

  Future<void> saveList(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'list_key';
    final value = jsonEncode(list);
    prefs.setString(key, value);
  }
}
