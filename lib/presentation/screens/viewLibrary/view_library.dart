import 'package:click_it_app/presentation/screens/viewLibrary/item_view_library.dart';
import 'package:click_it_app/presentation/screens/viewLibrary/view_library_response.dart';
import 'package:click_it_app/utils/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewLibraryScreen extends StatefulWidget{

  const ViewLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ViewLibraryScreen> createState() {
    return _ViewLibraryScreenState();
  }

}

class _ViewLibraryScreenState extends State<ViewLibraryScreen>{

  List<Data> viewLibraryData = List.empty();
  var page = 1;
  ScrollController _scController = new ScrollController();
  bool _isLoadMoreRunning = true;

  @override
  void initState() {
    //_isLoadMoreRunning = true;
    ClickItApis.getViewLibraryData(page).then(
            (value) {
              viewLibraryData = value!;
              if (mounted) {
                setState(() {
                  _isLoadMoreRunning = false;
                });
              }
            }
    );

    _scController.addListener(() {
      if (_scController.position.pixels ==
          _scController.position.maxScrollExtent) {
        page++;
        if(mounted) {
          setState(() {
            _isLoadMoreRunning = true;
          });
        }

        ClickItApis.getViewLibraryData(page).then(
                (value) {
                  viewLibraryData.addAll(value!);
                  if (mounted) {
                    setState(() {
                      _isLoadMoreRunning = false;
                    });
                  }
                }
        );
      }
    });

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Library"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(viewLibraryData.isEmpty)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                  controller: _scController,
                  itemCount: viewLibraryData.length,
                  itemBuilder: (BuildContext buildContext,int index){
                    return ItemViewLibrary(viewLibraryResponse: viewLibraryData[index]);
                  }),
            ),

            if (_isLoadMoreRunning == true&&viewLibraryData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
              ),
          ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scController.dispose();
    super.dispose();
  }

}

