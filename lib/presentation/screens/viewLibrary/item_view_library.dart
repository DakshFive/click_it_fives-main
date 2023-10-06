import 'package:click_it_app/presentation/screens/viewLibrary/item_view_image.dart';
import 'package:click_it_app/presentation/screens/viewLibrary/view_library_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemViewLibrary extends StatefulWidget{

  const ItemViewLibrary({Key? key,required this.viewLibraryResponse}) : super(key: key);

  final Data viewLibraryResponse;

  @override
  State<ItemViewLibrary> createState() {
    return _ItemViewLibraryState();
  }

}

class _ItemViewLibraryState extends State<ItemViewLibrary>{

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 4,bottom: 4,left: 8,right: 8),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.viewLibraryResponse.gtin ??'',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Text(widget.viewLibraryResponse.product_name ??'',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0,left: 8.0,top: 4,bottom: 4),
                  child: ElevatedButton(onPressed: (){

                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(" GTIN: "+widget.viewLibraryResponse.gtin!,
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                          content: Container(
                              width: double.minPositive,
                              height: 360,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: 8,
                                physics: ScrollPhysics(),
                                itemBuilder: (context, index) {

                                  if (index == 0) {
                                    if(widget.viewLibraryResponse.imageFront !=
                                        ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageFront??'', imageTitle: "Front Image");
                                    }

                                  } else if (index == 1) {
                                    if(widget.viewLibraryResponse.imageBack !=
                                        '') {
                                      if(widget.viewLibraryResponse.imageFront !=
                                          ''){
                                        return ItemViewImage(imagePath: widget.viewLibraryResponse.imageBack??'', imageTitle: "Back Image");
                                      }
                                    }
                                  } else if (index == 2) {
                                    if(widget.viewLibraryResponse.imageLeft !=
                                        ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageLeft??'', imageTitle: "Left Image");
                                    }

                                  } else if (index == 3) {
                                    if(widget.viewLibraryResponse.imageRight !=
                                        ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageRight??'', imageTitle: "Right Image");
                                    }

                                  } else if (index == 4) {
                                    if(widget.viewLibraryResponse.imageTop != ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageTop??'', imageTitle: "Top Image");
                                    }

                                  } else if (index == 5) {
                                    if(widget.viewLibraryResponse.imageBottom !=
                                        ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageBottom??'', imageTitle: "Bottom Image");
                                    }

                                  } else if (index == 6) {
                                    if(widget.viewLibraryResponse.imageNutritional !=
                                        ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageNutritional??'', imageTitle: "Nutritional Table");
                                    }

                                  } else if (index == 7) {
                                    if(widget.viewLibraryResponse.imageIngredients !=
                                        ''){
                                      return ItemViewImage(imagePath: widget.viewLibraryResponse.imageIngredients??'', imageTitle: "Ingredients");
                                    }

                                  }
                                  return Container();
                                },
                              )
                          ) ,
                        )
                    );

                  },style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero, // Set this
                    padding: EdgeInsets.only(left: 8,right: 8,top: 4,bottom: 4), // and this
                  ),
                      child: Text('View Images')),
                ),
              ),

            ],
          ),
        ));
  }


}