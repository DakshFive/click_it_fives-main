import 'dart:async';
import 'dart:convert';

import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/common/loader/visible_progress_loaded.dart';
import 'package:click_it_app/common/utility.dart';
import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/login_model.dart';
import 'package:click_it_app/preferences/app_preferences.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/uploadImages/new_home_screen.dart';
import 'package:click_it_app/presentation/widgets/bottom_logo_widget.dart';
import 'package:click_it_app/presentation/widgets/logo_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  StreamSubscription? connection;
  bool showProgressBar = false;

  @override
  void initState() {
    AppPreferences.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                LogoWidget(),
                Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: userNameController,
                        keyboardType: TextInputType.emailAddress,
                        /*inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^[a-zA-Z0-9_@]*$")),
                        ],*/
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        onSaved: (String? value) {
                          // This optional block of code can be used to run
                          // code when the user saves the form.
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (String? value) {
                          return (value != null)
                              ? 'Please enter password'
                              : null;
                        },
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      GestureDetector(
                        onTap: () async {
                          FocusManager.instance.primaryFocus?.unfocus();

                          if (userNameController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            Utils.isConnected().then((value) {

                              if(value){
                                VisibleProgressLoader.show(context);
                                loginApi(
                                  userNameController.text,
                                  passwordController.text,
                                  context,
                                );
                              }else{
                                Fluttertoast.showToast(
                                    msg: 'Please check your internet ',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }

                            });


                            }
                           else {
                            Fluttertoast.showToast(
                                msg: 'Please enter the credentials ',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                        child: Container(
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          height: 40.h,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const BottomLogoWidget(),
                SizedBox(
                  height: 40.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  loginApi(userName, password, BuildContext context) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Cookie':
            'ApplicationGatewayAffinity=2f967101da599eb0bb564bd1ae6b3983; ApplicationGatewayAffinityCORS=2f967101da599eb0bb564bd1ae6b3983; PHPSESSID=n2gpksvdd4lm7udpcpp7gk8lk4'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://gs1datakart.org/api/v501//manf_login?apiId=df4a3e288e73d4e3d6e4a975a0c3212d&apiKey=440f00981a1cc3b1ce6a4c784a4b84ea'));
      request.body = json.encode({"user_name": userName, "password": password});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        //  print(await response.stream.bytesToString());

        VisibleProgressLoader.hide();

        final data = jsonDecode(await response.stream.bytesToString());

        print('data is $data');

        //store the login credentials in shared preferences

        await AppPreferences.addSharedPreferences(
            data['company_name'], 'company_name');

        await AppPreferences.addSharedPreferences(data['source'], 'login_data');

        print('sdmsf');
        print('${AppPreferences.getValueShared('login_data')}');
        print(data['company_id']);
        print(data['source']);
        print(data['role_id']);
        print(data['uid']);
        data['source'] == 'member'
            ? await AppPreferences.addSharedPreferences(
            data['company_id'][0], 'company_id')
            : await AppPreferences.addSharedPreferences(
            data['company_id'], 'company_id');
        await AppPreferences.addSharedPreferences(data['source'], 'source');
        await AppPreferences.addSharedPreferences(data['role_id'], 'role_id');
        await AppPreferences.addSharedPreferences(data['uid'], 'uid');
        print('login successfull');
        Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const NewHomeScreen(isShowRatingDialog: false,),
            ));
      } else {
        VisibleProgressLoader.hide();

        print(response.reasonPhrase);

        Fluttertoast.showToast(msg: "Please check your username or password");
      }
    } on Exception catch (e) {
      // TODO
      VisibleProgressLoader.hide();
      Fluttertoast.showToast(msg: "Something went wrong. Please try again");
    }
  }

  /*Future<bool> isConnected() async{
    bool isonline = true;
    connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result){
      // whenevery connection status is changed.
      if(result ==  ConnectivityResult.none){
        //there is no any connection
        isonline = false;
      }else if(result ==  ConnectivityResult.mobile){
        //connection is mobile data network

        isonline = true;
      }else if(result ==  ConnectivityResult.wifi){
        //connection is from wifi

        isonline = true;
      }else if(result ==  ConnectivityResult.ethernet){
        //connection is from wired connection

        isonline = true;
      }else if(result ==  ConnectivityResult.bluetooth){
        //connection is from bluetooth threatening

        isonline = true;

      }
    });

    return isonline;


  }


  void cancelConnectionCheck(){
    connection?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    cancelConnectionCheck();
  }*/
}
