import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:store_redirect/store_redirect.dart';

class _RatingsScreenState extends State<RatingsScreen> {
  // show the rating dialog
  void _showRatingDialog() {
    // actual store listing review & rating
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
        /*_inAppReview.openStoreListing(
          appStoreId: '<your app store id>',
          microsoftStoreId: '<your microsoft store id>',
        );*/
      }
    }

    final _dialog = RatingDialog(
      enableComment: false,
      initialRating: 0.0,
      // your app's name?
      title: Text(
        'Would you like to rate us?',
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // encourage your user to leave a high rating?
      message: Text(
        'It will help us grow',
        textAlign: TextAlign.start,
        style: const TextStyle(fontSize: 15),
      ),
      // your app's logo?
      image: Image.asset('assets/images/icon.png',width: 50,height: 50,),
      submitButtonText: 'Rate now',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, comment: ${response.comment}');
        _rateAndReviewApp();
        /*
        if (response.rating < 3.0) {
          // send their comments to your email or anywhere you wish
          // ask the user to contact you instead of leaving a bad review
        } else {
          _rateAndReviewApp();
        }*/
      },
    );

    // show the dialog
    showDialog(
      useSafeArea: true,
      context: context,
      barrierDismissible: true, // set to false if you want to force a rating
      builder: (context) => _dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating Dialog Example')),
      body: Center(
        child: Container(
          padding: MediaQuery.of(context).padding,
          child: ElevatedButton(
            child: const Text('Show Rating Dialog'),
            onPressed: _showRatingDialog,
          ),
        ),
      ),
    );
  }
}

class RatingsScreen extends StatefulWidget {
  const RatingsScreen();

  @override
  _RatingsScreenState createState() => new _RatingsScreenState();
}