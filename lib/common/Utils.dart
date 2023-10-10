import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'dart:io' show File, InternetAddress, Platform, SocketException;


class Utils {


  static Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
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
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  static Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  // static Future<LatLng> getUserLocation(BuildContext context) async {
  //   try {
  //     if (Platform.isIOS) {
  //       var position = await GeolocatorPlatform.instance
  //           .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //       LatLng currentPosition = LatLng(position.latitude, position.longitude);
  //       return currentPosition;
  //     }

  //     if (Platform.isAndroid) {
  //       if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
  //         var position = await GeolocatorPlatform.instance
  //             .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //         LatLng currentPostion = LatLng(position.latitude, position.longitude);
  //         return currentPostion;
  //       } else {
  //         // Fluttertoast.showToast(msg: "Please Give location permission to lodge complaint");
  //       }
  //     }
  //   } catch (e) {
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) => CupertinoAlertDialog(
  //               title: Text('Grant Location Permission'),
  //               content: Text(
  //                   'This app needs location permission to register complaints'),
  //               actions: <Widget>[
  //                 CupertinoDialogAction(
  //                   child: Text('Deny'),
  //                   onPressed: () => Navigator.of(context).pop(),
  //                 ),
  //                 // CupertinoDialogAction(
  //                 //   child: Text('Settings'),
  //                 //   onPressed: () => openAppSettings(),
  //                 // ),
  //               ],
  //             ));
  //   }
  // }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(Platform.isAndroid){
        await Geolocator.openLocationSettings();
      }else{
        await Geolocator.openAppSettings();
      }
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static String encodeImage(File? image) {
    final bytes = image!.readAsBytesSync();
    String encodedImage = "data:image/png;base64," + base64Encode(bytes);

    return encodedImage;
  }

  static Image decodeString(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  static Future<bool> isConnected() async{
    bool isonline = false;
    ConnectivityResult result = await Connectivity().checkConnectivity();
    // whenevery connection status is changed.
      if(result == ConnectivityResult.none){
        //there is no any connection
          isonline = false;
      }else if(result == ConnectivityResult.mobile){
        //connection is mobile data network

        isonline = true;
      }else if(result == ConnectivityResult.wifi){
        //connection is from wifi

        isonline = true;
      }else if(result == ConnectivityResult.ethernet){
        //connection is from wired connection

        isonline = true;
      }else if(result == ConnectivityResult.bluetooth){
        //connection is from bluetooth threatening

        isonline = false;

      }

    if(isonline){
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          isonline = true;
          print('connected');
        }
      } on SocketException catch (_) {
        isonline = false;
        print('not connected');
      }
    }

    return isonline;


  }

  static askLocationPermission() async{
    LocationPermission permission;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
      if(permission == LocationPermission.whileInUse||permission == LocationPermission.always){
        if (!serviceEnabled) {
          if(Platform.isAndroid){
            await Geolocator.openLocationSettings();
          }else{
            await Geolocator.openAppSettings();
          }

          // Location services are not enabled don't continue
          // accessing the position and request users of the
          // App to enable the location services.
          return Future.error('Location services are disabled.');
        }
      }
    }
  }


}