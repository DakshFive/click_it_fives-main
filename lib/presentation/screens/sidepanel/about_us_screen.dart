import 'package:click_it_app/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarSidePanel(title: const Text('About Us'), appBar: AppBar()),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: const Text(
            'ClickIt is an intuitive and easy-to-use photo app that enables product manufacturers to take catalogue-ready product photos to list them with online marketplaces.\n\nOnce taken,the photos get synced with the Datakart account of manufacturers,where they can edit these using global imaging standards.',style: TextStyle(fontSize: 14,),),
      ),
    );
  }
}
