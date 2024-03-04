import 'package:click_it_app/presentation/widgets/app_bar_widget.dart';
import 'package:click_it_app/utils/app_images.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us',style: TextStyle(fontSize: 18),),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppImages.backgroundImage),
              fit: BoxFit.cover,
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: const Text(
                'ClickIt is an intuitive and easy-to-use photo app that enables product manufacturers to take catalogue-ready product photos to list them with online marketplaces.\n\nOnce taken,the photos get synced with the Datakart account of manufacturers,where they can edit these using global imaging standards.'
                ,style: TextStyle(fontSize: 16,),),
            ),

          ]
        ),


      ),
    );
  }
}
