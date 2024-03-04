import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewProductImage extends StatelessWidget {
  final image;
  const ViewProductImage({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('+++${image.runtimeType}');
    print('+++${image.runtimeType == Uint8List}');

    if (image is Uint8List) {
      return Scaffold(
          body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: false,
            boundaryMargin: EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2,
            child: Center(child: Image.memory(image)),
          ),
          Positioned(
              right: 10,
              top: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.grey,
                  size: 30,
                ),
                color: Colors.black,
              )),
        ],
      ));
    } else if (image is String) {
      return Scaffold(
          body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: false,
            boundaryMargin: EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2,
            child: Center(child: Image.file(File(image))),
          ),
          Positioned(
              right: 10,
              top: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.grey,
                  size: 30,
                ),
                color: Colors.black,
              )),
        ],
      ));
    } else {
      return Scaffold(
          body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: false,
            boundaryMargin: EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2,
            child: Center(child: Image.file(image)),
          ),
          Positioned(
              right: 10,
              top: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.grey,
                  size: 30,
                ),
                color: Colors.black,
              )),
        ],
      ));
    }
  }
}

Widget cachedNetworkImage(
    {required String url, double? height, double? width}) {
  return CachedNetworkImage(
    imageUrl: url,
    progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: CircularProgressIndicator(
      value: downloadProgress.progress,
      color: Colors.orange,
    )),
    height: height,
    width: width,
  );
}
