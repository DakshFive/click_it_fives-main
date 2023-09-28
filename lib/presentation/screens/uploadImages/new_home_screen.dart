import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/home/sync_server_screen.dart';
import 'package:click_it_app/presentation/screens/settings/settings_sreen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/sync_server_screen_new.dart';
import 'package:click_it_app/presentation/screens/viewLibrary/view_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewHomeScreen extends StatefulWidget{

  const NewHomeScreen({Key? key,required this.isShowRatingDialog}) : super(key: key);
  final isShowRatingDialog;

  @override
  State<StatefulWidget> createState() {
    return _NewHomeScreenState();
  }
}

class _NewHomeScreenState extends State<NewHomeScreen>{

  int _selectedIndex = 0;

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(isShowRatingDialog: false),
    SyncServerScreenNew(),
    ViewLibraryScreen(),
    SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Saved Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        selectedFontSize: 12,
      ),
    );
  }
}