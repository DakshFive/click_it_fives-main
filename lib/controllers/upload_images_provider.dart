import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../data/data_sources/remote_data_source.dart';
import '../data/models/get_images_model.dart';

class UploadImagesProvider extends ChangeNotifier {
  bool _isBackgroundRemovalInProgress = false;

  bool get isBackgroundRemovalInProgress => _isBackgroundRemovalInProgress;

  setBackgroundRemoval(bool value) {
    _isBackgroundRemovalInProgress = value;
    notifyListeners();
  }

  Future<String?> getImageResolution(File? productImage) async {
    // EasyLoading.show(status: 'Checking Image Resolution...');

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://20.204.169.52:8080/get-score/front'));
      request.files
          .add(await http.MultipartFile.fromPath('front', productImage!.path));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String jsonData = await response.stream.bytesToString();

        return jsonDecode(jsonData)['sanity_check']['front'];
      } else {
        print(response.reasonPhrase);
        EasyLoading.showError('Please Upload again...');
        return null;
      }
    } on Exception catch (e) {
      EasyLoading.showError('Please Upload again...');

      return null;
    }
  }

  Future<Uint8List?> removeImagebackground(File? productImage) async {
    // EasyLoading.show(status: 'Editing Image...');

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
        EasyLoading.showError('Please Upload again...');
        return null;
      }
    } on Exception catch (e) {
      EasyLoading.showError('Please Upload again...');
    }
    return null;
  }

  // void getProductImages(String scanResult) async {
  //   print(scanResult);

  //   GetImagesRequestModel requestModel =
  //       GetImagesRequestModel(gtin: scanResult);

  //   Client _client = Client();
  //   RemoteDataSource dataSource = RemoteDataSourceImple(_client);

  //   await dataSource.getImages(requestModel).then((value) {
  //     print('get images completed');

  //     //saving the fetched images to database

  //     print(value.imageFront);
  //     print(value.imageBack);
  //     print(value.imageLeft);
  //     print(value.imageRight);

  //     print(value.imageRight);
  //     print(value.imageRight);
  //     print(value.imageRight);
  //     print(value.imageRight);
  //     print(value.imageRight);

  //     notifyListeners();
  //   }).onError((error, stackTrace) {
  //     Fluttertoast.showToast(msg: error.toString());
  //   });
  // }
}
