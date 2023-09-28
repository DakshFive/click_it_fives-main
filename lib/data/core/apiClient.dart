import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // **Bg Remove Fuction
  Future<Uint8List> remo(String imagepath) async {
    try {
      String imageRemovalUrl = "http://20.204.169.52:8090/backgroundRemoval";
      print(' Api Client fucntion');
      var uri = Uri.parse(imageRemovalUrl);
      var request = new http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('image', imagepath));

      final response = await request.send();

      if (response.statusCode == 200) {
        // Loader show
   
        http.Response imgres = await http.Response.fromStream(response);
        print(imgres.body);
        print(imgres);

        return imgres.bodyBytes;
      } else {
        throw Exception("Error Sending Data${response.statusCode}");
      }
    } catch (e) {
      throw e;
    }
  }
}
