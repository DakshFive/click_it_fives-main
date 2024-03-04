


import 'dart:io';

import 'package:click_it_app/presentation/widgets/star_rating_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidgetClickIt extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _RatingWidgetClickItState();
  }
}
late final TextEditingController _reviewDetailController;

class _RatingWidgetClickItState extends State<RatingWidgetClickIt>{

  double rating = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reviewDetailController = TextEditingController();

  }
  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration.zero,(){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder:(BuildContext context)
      {
        return AlertDialog(
            title: const Text('Rating and feedback',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Rate ClickIt',
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: RatingBar(
                      allowHalfRating: false,
                      initialRating: 0,
                      itemCount: 5,
                      maxRating: 5,
                      minRating: 0,
                      itemSize: 30.0,
                      ratingWidget: RatingWidget(
                        full: const Icon(Icons.star, color: Colors.blueAccent),
                        half: const Icon(
                            Icons.star_half, color: Colors.yellowAccent),
                        empty: const Icon(
                            Icons.star_border, color: Colors.blueAccent),
                      ),
                      onRatingUpdate: (rating) {

                      },

                    ),
                  ),

                  //Text('Would you like to approve of this message?'),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write feedback',
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {

                      }, child: Text('Submit'))
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
        child: const Text('Approve'),
        onPressed: () {
        Navigator.of(context).pop();
        },)
            ]
        );
      });
    });
    return Container();


  }



}

/*SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 28),
              Container(
                margin:
                EdgeInsets.only(left: 16, right: 20),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ratings & Reviews",
                        style:TextStyle(
                        fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,),),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          },
                        child: Icon(Icons.close))
                  ],
                ),
              ),
              SizedBox(height: 28),
              Divider(
                height: 0,
                color: Colors.white70,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  StarRating(
                    size: 40,
                    color: Colors.deepOrange,
                    rating: rating,
                    onRatingChanged: (rating) {

                    },
                  ),
                ],
              ),
              SizedBox(height: 23),
              Container(
                margin: EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                    "Feedback",
                    ),
              ),
              SizedBox(height: 9),
              Container(
                margin:
                EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                      border: InputBorder.none),
                ),
              ),
              SizedBox(height: 32),
              Container(
                margin:
                EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                    onPressed: () {},
                  child: Text('Submit'),

              ),),
              SizedBox(height: Platform.isIOS ? 25 : 9),
            ],
          ),
        );*/