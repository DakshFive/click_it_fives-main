import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/common/utility.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/db_handler.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/get_images_model.dart';
import 'package:click_it_app/data/models/local_sync_images_model.dart';
import 'package:click_it_app/data/models/photo.dart';
import 'package:click_it_app/data/models/upload_images_model.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/home/show_image.dart';
import 'package:click_it_app/presentation/screens/home/sync_server_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;

class ImageUploadGrid extends StatefulWidget {
  const ImageUploadGrid({Key? key}) : super(key: key);

  @override
  State<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends State<ImageUploadGrid> {
  File? frontImage, backImage, leftImage, rightImage;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};
//static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  DatabaseHelper? databaseHelper;

  String longitudeData = "";
  String latitudeData = "";
  String imei = "";

  //already available product images

  String? productFrontImage,
      productBackImage,
      productLeftImage,
      productRightImage;
  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
          width: MediaQuery.of(context).size.width,
          height: kToolbarHeight,
          child: ElevatedButton(onPressed: () {}, child: Text("Submit"))),
      appBar: AppBar(
        title: Text("Upload Images"),
      ),
      body: Scrollbar(
          isAlwaysShown: true,
          controller: _controller,
          thickness: 10,
          radius: Radius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.count(
              controller: _controller,
              crossAxisCount: 2,
              children: <Widget>[
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Front",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "High",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                            onTap: () {
                              bottomsheetUploads(context, 'frontImage');
                            },
                            child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Back",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "High",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Left",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "High",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Right"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                        SizedBox(
                          height: 32,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text("High"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Top"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                        SizedBox(
                          height: 32,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text("High"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Bottom"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                        SizedBox(
                          height: 32,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text("High"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Nutrition Val"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                        SizedBox(
                          height: 32,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text("High"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    height: 15,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image
                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Ingredients"),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                        SizedBox(
                          height: 32,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text("High"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 15.0),
                    decoration: BoxDecoration(
                        // TODO ADD  Image File Image

                        // image: DecorationImage(
                        //   image: FileImage(frontImage!),
                        //   fit: BoxFit.cover,

                        //   // fit: BoxFit.fill,
                        //   alignment: Alignment.center,
                        // ),
                        ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                "Edited",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     "High",
                            //     style: TextStyle(color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(onTap: () {}, child: Icon(Icons.add)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Front Original Image",
                //             style: TextStyle(fontSize: 17.0),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Front Edited Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Card(
                //   child: InkWell(
                //     onTap: () {},
                //     splashColor: Colors.grey,
                //     child: Center(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add,
                //             size: 50,
                //           ),
                //           Text(
                //             "Upload Image",
                //             style: TextStyle(fontSize: 17.0),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
            // GridView.builder(
            //   itemCount: 50,
            //   itemBuilder: (BuildContext context, int index) {
            //     return GestureDetector(
            //       onTap: () {

            //       },
            //       child: Container(
            //         color: Colors.grey,
            //         child: Center(
            //           child: Icon(Icons.add),
            //         ),
            //       ),
            //     );
            //   },
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     mainAxisSpacing: 20,
            //     crossAxisSpacing: 20,
            //     crossAxisCount: 2,
            //   ),
            // ),
          )),
    );
  }

  Future<dynamic> bottomsheetUploads(BuildContext context, String imageType) {
    print('the imageType in front image is $imageType');
    return showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.white,
      transitionBackgroundColor: Colors.yellow,
      builder: (context) {
        return Material(
          child: Container(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ListTile(
                  onTap: () => pickImage('camera', imageType),
                  title: const Text('Camera'),
                ),
                const Divider(
                  height: 1.0,
                ),
                ListTile(
                  onTap: () => pickImage('gallery', imageType),
                  title: const Text('Gallery'),
                ),
                const Divider(
                  height: 2.0,
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  title: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Null> pickImage(String source, String imageType) async {
    try {
      final imagePicked = await ImagePicker().pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      );

      if (imagePicked == null) return;
      //user has selected the image
      final imageTemporary = File(imagePicked.path);

      //user has selected the image
      // _cropImage(imageTemporary, imageType);
      // ** api call resoltion

      var imageQualityUrl = "http://20.204.169.52:8080/get-score/front";
      var imageData = {"front": frontImage};
      var bodydata = jsonEncode(imageData);
      var urlParse = Uri.parse(imageQualityUrl);
      Response response = await http.post(
        urlParse,
        body: bodydata,
      );
      var datares = response.body;

      print(datares);
      if (response == 201) {
        print("Success checked Quality");
      } else {
        print("Bad Image");
      }
    } on PlatformException catch (e) {
      //exception could occur if the user has not permitted for the picker

      print('Failed to pick image: $e');
    }
  }

  // Future<Null> _cropImage(File? image, String imageType) async {
  //   File? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: image!.path,
  //       maxWidth: 420,
  //       maxHeight: 420,
  //       aspectRatioPresets: Platform.isAndroid
  //           ? [
  //               CropAspectRatioPreset.square,
  //               CropAspectRatioPreset.ratio3x2,
  //               CropAspectRatioPreset.original,
  //               CropAspectRatioPreset.ratio4x3,
  //               CropAspectRatioPreset.ratio16x9
  //             ]
  //           : [
  //               CropAspectRatioPreset.original,
  //               CropAspectRatioPreset.square,
  //               CropAspectRatioPreset.ratio3x2,
  //               CropAspectRatioPreset.ratio4x3,
  //               CropAspectRatioPreset.ratio5x3,
  //               CropAspectRatioPreset.ratio5x4,
  //               CropAspectRatioPreset.ratio7x5,
  //               CropAspectRatioPreset.ratio16x9
  //             ],
  //       androidUiSettings: const AndroidUiSettings(
  //           toolbarTitle: 'Cropper',
  //           toolbarColor: Colors.deepOrange,
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: false),
  //       iosUiSettings: const IOSUiSettings(
  //         title: 'Cropper',
  //       ));

  //   if (croppedFile != null) {
  //     // Uint8List imagebytes = await croppedFile.readAsBytes(); //convert to bytes
  //     // String base64string =
  //     //     base64.encode(imagebytes); //convert bytes to base64 string
  //     // print('the base64string is ${base64string}');

  //     Navigator.pop(context, image);
  //     setState(() {
  //       print('the current imagetype is $imageType');
  //       if (imageType == 'frontImage') {
  //         frontImage = croppedFile;
  //       } else if (imageType == 'backImage') {
  //         backImage = croppedFile;

  //         print(backImage);
  //       } else if (imageType == 'leftImage') {
  //         leftImage = croppedFile;
  //       } else {
  //         rightImage = croppedFile;
  //       }
  //     });
  //   }
  // }
}
