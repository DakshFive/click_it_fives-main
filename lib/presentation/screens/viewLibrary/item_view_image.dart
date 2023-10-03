import 'package:cached_network_image/cached_network_image.dart';
import 'package:click_it_app/presentation/screens/viewLibrary/view_library_response.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemViewImage extends StatefulWidget{

  const ItemViewImage({Key? key,required this.imagePath,required this.imageTitle}) : super(key: key);
  final String imagePath;
  final String imageTitle;
  
  @override
  State<StatefulWidget> createState() {
    return _ItemViewImageState();
  }
}

class _ItemViewImageState extends State<ItemViewImage>{

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: 230,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: widget.imagePath !=
                  ''
                  ? CachedNetworkImage(
                imageUrl: widget.imagePath,
                placeholder: (context, url) => Center(child: new CircularProgressIndicator()),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              )
              /*Image.network(
                  widget.imagePath,
                fit: BoxFit.scaleDown,
              )*/

                  : DottedBorder(child: SizedBox(height: 230,)),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Row(
              children: [
                Text(
                widget.imageTitle,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                )
            ),
          SizedBox(width: 10,),
          IconButton(
            onPressed: (){

            },
            icon: Icon(Icons.share),color: Colors.black,)
        ]
            ),
          ),
        ]
    );
  }
}