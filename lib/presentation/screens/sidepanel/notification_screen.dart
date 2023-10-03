import 'package:click_it_app/presentation/widgets/app_bar_widget.dart';
import 'package:click_it_app/utils/app_images.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification',style: TextStyle(fontSize: 18),),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.backgroundImage),
              fit: BoxFit.cover,
            )
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1.When cropping the image ,kindly ensure there is minimum space of '
                      '4-5 mm on all four sides. This '
                      'will result in a well-proportioned view of the product, '
                      'allowing its features to be presented appropriately.'
                  ,style: TextStyle(fontSize: 16,),),
                SizedBox(height: 8,),
                const Text(
                  '2. A fresh version of the app has been released!'
                  ,style: TextStyle(fontSize: 16,),),
                SizedBox(height: 8,),
                const Text(
                  '3. An app tour has been implemented to enhance your understanding of the application\'s feature.'
                  ,style: TextStyle(fontSize: 16,),),
                SizedBox(height: 8,),
                const Text(
                  '4. Viewing locally saved images and manual synchronization to the datakart server are now simpler tasks.'
                  ,style: TextStyle(fontSize: 16,),),
                SizedBox(height: 8,),

              ]
          ),
        ),


      ),
    );
  }
}
