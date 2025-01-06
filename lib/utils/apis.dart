import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:click_it_app/presentation/screens/viewLibrary/view_library_response.dart';
import 'package:click_it_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

class ClickItApis{

  // Create a pinned HttpClient 
  static Future<HttpClient> createPinnedHttpClient() async { 
    final ByteData data = await rootBundle.load('assets/certificates/my_cert.pem'); 
    final trustedCert = Uint8List.view(data.buffer); 
 
    SecurityContext context = SecurityContext(); 
    context.setTrustedCertificatesBytes(trustedCert); 
 
    final HttpClient httpClient = HttpClient(context: context); 
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) { 
      return false; // Reject mismatched certificates 
    }; 
 
    return httpClient; 
  } 
 
  // Fetch View Library Data with SSL pinning 
  static Future<List<Data>?> getViewLibraryData( 
      int page, String uid, String companyID, int roleId) async { 
    var queryParams = { 
      'apiId': ClickItConstants.APIID, 
      'apiKey': ClickItConstants.APIKEY, 
      'uid': uid, 
      'company_id': companyID, 
      'role_id': roleId, 
      'page_no': page, 
    }.map((key, value) => MapEntry(key, value.toString())); 
 
    var uri = Uri.https('gs1datakart.org', '/api/v501/recent_uploaded_images', queryParams); 
 
    try { 
      final httpClient = await createPinnedHttpClient(); 
      final ioClient = IOClient(httpClient); 
 
      final response = await ioClient.post( 
        uri, 
        headers: {"content-type": "application/json"}, 
      ).timeout(Duration(seconds: 60)); 
 
      if (response.statusCode == 200) { 
        print(utf8.decoder.convert(response.bodyBytes)); 
        try { 
          return ViewLibraryResponse.fromJson(json.decode(utf8.decoder.convert(response.bodyBytes))).data; 
        } catch (e) { 
          return []; 
        } 
      } else { 
        return []; 
      } 
    } on TimeoutException catch (e) { 
      return []; 
    } 
  } 
 
  // Compress Image with SSL pinning 
  static Future<Uint8List?> getCompressedImage(String path) async { 
    try { 
      final httpClient = await createPinnedHttpClient(); 
      final ioClient = IOClient(httpClient); 
 
      var request = http.MultipartRequest( 
        'POST', 
        Uri.parse('http://4.240.61.161:4002/compress'), 
      ); 
 
      request.files.add(await http.MultipartFile.fromPath('image', path)); 
 
      http.StreamedResponse response = await ioClient.send(request).timeout(Duration(seconds: 60)); 
 
      if (response.statusCode == 200) { 
        return await response.stream.toBytes(); 
      } else { 
        print(response.reasonPhrase); 
        return null; 
      } 
    } on Exception catch (e) { 
      return null; 
    } 
  } 


}
