import 'package:root_check/root_check.dart'; 


class RootCheckerUtil {
  Future<bool> isDeviceRooted() async {
    bool isRooted = false;

    try {
      isRooted = (await RootCheck.isRooted)!;
    } catch (e) {
      print("Error checking root status: $e");
    }

    return isRooted;
  }
}