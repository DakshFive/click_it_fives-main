import 'dart:convert';

import 'package:click_it_app/data/core/api_constants.dart';
import 'package:click_it_app/data/models/get_images_model.dart';
import 'package:click_it_app/data/models/login_model.dart';
import 'package:click_it_app/data/models/upload_images_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class RemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel requestModel);

  Future<GetImagesResponseModel> getImages(GetImagesRequestModel requestModel);

  Future uploadImages(UploadImagesRequestModel requestModel);

}



class RemoteDataSourceImple extends RemoteDataSource {
  final Client _client;

  RemoteDataSourceImple(this._client);

  @override
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    
    
   String url='${ApiConstants.BASE_URl}/manf_login?apiId=${ApiConstants.API_ID}&apiKey=${ApiConstants.API_KEY}';
  
    var response = await _client.post(
      Uri.parse(url),
      body: requestModel.toJson(),
    );

    print(requestModel.toJson());
    print(url);
    print(response.statusCode);

    if (response.statusCode == 200) {
      print('resonse found');
      print(response);

      String responseBody = utf8.decoder.convert(response.bodyBytes);
      print(responseBody);
      return LoginResponseModel.fromJson(json.decode(responseBody));

    
    } else {
      print('error in response  ${response.reasonPhrase}');

      Fluttertoast.showToast(
          msg: ' ${response.reasonPhrase}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      throw Exception(response.reasonPhrase);
    }
  
  }

  @override
  Future<GetImagesResponseModel> getImages(
      GetImagesRequestModel requestModel) async {
    
    String url='${ApiConstants.BASE_URl}/product_images?apiId=${ApiConstants.API_ID}&apiKey=${ApiConstants.API_KEY}';
    var response =
        await _client.post(Uri.parse(url), body: requestModel.toJson());

    print(requestModel.toJson());

    if (response.statusCode == 200) {
      print('response found');

      print(response);
      String responseBody = utf8.decoder.convert(response.bodyBytes);
      return GetImagesResponseModel.fromJson(json.decode(responseBody));
    } else {
      print('error in response ${response.reasonPhrase}');

      Fluttertoast.showToast(
          msg: ' ${response.reasonPhrase}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      throw Exception(response.reasonPhrase);
    }
 
 
  }

  @override
  Future uploadImages(UploadImagesRequestModel requestModel) async {
   
 
 String url='${ApiConstants.BASE_URl}/image_capture_new?apiId=${ApiConstants.API_ID}&apiKey=${ApiConstants.API_KEY}';

 print(requestModel.toJson());
 
    var response =
        await _client.post(Uri.parse(url), body: requestModel.toJson());

    print(requestModel.toJson());

    if (response.statusCode == 200) {
     

      print(response);
    } else {
      print('error in response ${response.reasonPhrase}');

       EasyLoading.showError('${response.reasonPhrase}');

       EasyLoading.dismiss();
      // Fluttertoast.showToast(
      //     msg: ' ${response.reasonPhrase}',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      throw Exception(response.reasonPhrase);
      
    }
  }
}

 