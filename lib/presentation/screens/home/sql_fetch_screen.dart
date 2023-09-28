import 'dart:io';

import 'package:click_it_app/common/utility.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class SaveImageDemoSQLite extends StatefulWidget {
   
  SaveImageDemoSQLite() : super();

  final String title = "Flutter Save Image";

  @override
  _SaveImageDemoSQLiteState createState() => _SaveImageDemoSQLiteState();

}

class _SaveImageDemoSQLiteState extends State<SaveImageDemoSQLite> {
  //
 late Future<File?> imageFile;
  Image? image;
  DatabaseHelper? dbHelper;
  List<Photo> images=[];

  @override
  void initState() {
    super.initState();
    images = [];
    dbHelper = DatabaseHelper();
    refreshImages();
  }

  refreshImages() {
    dbHelper?.getPhotos().then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }




    Future<Null> pickImage(String source,) async {
    try {
      final imagePicked = await ImagePicker().pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      );

      //checking if the user has selected the image
      if (imagePicked == null) return ;

      //user has selected the image
      final imageTemporary = File(imagePicked.path);


      String imgString = Utility.base64String(imageTemporary.readAsBytesSync());
   //   Photo photo = Photo(0, imgString,'','','','',);
      
    //  dbHelper?.save(photo);
      refreshImages();
   
    } on PlatformException catch (e) {
      //exception could occur if the user has not permitted for the picker

      print('Failed to pick image: $e');
      

    }

  }



  // gridView() {
  //   return Padding(
  //     padding: EdgeInsets.all(5.0),
  //     child: GridView.count(
  //       crossAxisCount: 2,
  //       childAspectRatio: 1.0,
  //       mainAxisSpacing: 4.0,
  //       crossAxisSpacing: 4.0,
  //       children: images.map((photo) {
  //         return Utility.imageFromBase64String(photo.photo_name!);
  //       }).toList(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              pickImage('gallery');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

             

            
        //     Flexible(
           
        //   child: Container(
        //     height: 100,
        //     child: ListView(children: images.map((photo) {
        //     return Utility.imageFromBase64String(photo.photo_name!);
        // }).toList(),
        // scrollDirection: Axis.horizontal,),
        //   ),
        //     )
          ],
        ),
      ),
    );
  }
}