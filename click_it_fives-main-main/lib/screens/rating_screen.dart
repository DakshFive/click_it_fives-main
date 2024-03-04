
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:in_app_review/in_app_review.dart';

import '../preferences/app_preferences.dart';

class RatingScreenCustom extends StatefulWidget{

  const RatingScreenCustom({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RatingScreenCustomState();
  }

}

class _RatingScreenCustomState extends State<RatingScreenCustom>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppPreferences.init();
  }

  @override
  Widget build(BuildContext context) {
    final _content = Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Image.asset('assets/images/icon.png',width: 50,height: 50,),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Would you like to rate us?',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          ),
                          SizedBox(height: 10,),
                          Text('It will help us grow',
                          softWrap: true,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    )

                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: RatingBar.builder(
                        initialRating:0,
                        glowColor: Colors.deepOrange,
                        minRating: 0,
                        itemSize: 25,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        onRatingUpdate: (rating) {
                          setState(() {

                          });
                        },
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Text('Enjoying ClickIt?',
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],

                ),
                TextButton(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: Icon(Icons.arrow_forward_ios),
                    ),
                    Text('Rate Now',
                    style: TextStyle(
                      fontSize: 14
                    ),),
                    Icon(Icons.arrow_forward_ios,size: 10,),
                  ],),
                  onPressed: ()  async{
                    await AppPreferences.addSharedPreferences(false, "isShowRating");
                    Navigator.pop(context);
                   _rateAndReviewApp();
                  /*onPressed: _response!.rating == 0
                      ? null
                      : () {
                    if (!widget.force) Navigator.pop(context);
                    _response!.comment = _commentController.text;
                    widget.onSubmitted.call(_response!);*/
                  },
                ),
              ],
            ),
          ),
        ),

          /*IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              Navigator.pop(context);
            },
          )*/
      ],
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      titlePadding: EdgeInsets.zero,
      scrollable: true,
      title: _content,
    );
  }

  void _rateAndReviewApp() async {
    // refer to: https://pub.dev/packages/in_app_review
    final _inAppReview = InAppReview.instance;
    //StoreRedirect.redirect(androidAppId: 'com.techautovity.pictureit',iOSAppId: '');
    if (await _inAppReview.isAvailable()) {
      print('request actual review from store');
      _inAppReview.requestReview();
    } else {

      print('open actual store listing');
      // TODO: use your own store ids
      _inAppReview.openStoreListing(
          appStoreId: '1621992445',
        );
    }
  }

}