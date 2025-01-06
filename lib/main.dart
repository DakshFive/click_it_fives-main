import 'dart:io'; 
import 'package:click_it_app/controllers/upload_images_provider.dart'; 
import 'package:click_it_app/presentation/screens/Splash/splash_screen.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart'; 
import 'package:flutter_easyloading/flutter_easyloading.dart'; 
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:logger/logger.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:provider/provider.dart'; 
import 'package:root_check/root_check.dart'; 
 
import 'utils/root_check.dart'; // Import your RootCheckerUtil 
 
void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  FlutterError.onError = (FlutterErrorDetails details) { 
    saveErrorToFile(details); 
  }; 
 
  // Root check integration 
  final rootChecker = RootCheckerUtil(); 
  final isRooted = await rootChecker.isDeviceRooted(); 
 
  if (isRooted) { 
    // Handle rooted device case 
    print("Device is rooted."); 
    runApp(RootedDeviceScreen()); 
  } else { 
    // Proceed with normal app flow 
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]) 
        .then((value) => runApp(MyApp())); 
  } 
 
  if (kDebugMode) { 
    Logger.level = Level.debug; 
  } 
} 
 
Future<void> saveErrorToFile(FlutterErrorDetails errorDetails) async { 
  try { 
    final directory = await getExternalStorageDirectory(); 
    final documentsPath = '${directory!.path}/ClickITApp'; 
    final folderPath = '$documentsPath/CrashReports'; 
    final folder = Directory(folderPath); 
    if (!folder.existsSync()) { 
      folder.createSync(recursive: true); 
    } 
 
    final fileName = '${DateTime.now().millisecond}crash_log.txt'; 
    final file = File('$folderPath/$fileName'); 
    final crashLog = errorDetails.toString(); 
    await file.writeAsString(crashLog); 
 
    print('Crash report saved at: ${file.path}'); 
  } catch (e) { 
    print('Failed to save crash log: $e'); 
  } 
} 
 
class MyApp extends StatelessWidget { 
  const MyApp({Key? key}) : super(key: key); 
 
  @override 
  Widget build(BuildContext context) { 
    return MultiProvider( 
      providers: [ 
        ChangeNotifierProvider(create: (_) => UploadImagesProvider()), 
      ], 
      child: ScreenUtilInit( 
        designSize: Size(360, 690), 
        minTextAdapt: true, 
        splitScreenMode: true, 
        builder: (context, child) => MaterialApp( 
          title: 'ClickIt App', 
          theme: ThemeData(primarySwatch: Colors.deepOrange), 
          debugShowCheckedModeBanner: false, 
          home: const SplashScreen(), 
          builder: EasyLoading.init(), 
        ), 
      ), 
    ); 
  } 
} 
 
class RootedDeviceScreen extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return MaterialApp( 
      home: Scaffold( 
        body: Center( 
          child: Text( 
            'This device is rooted. The app cannot run on rooted devices.', 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 18, color: Colors.red), 
          ), 
        ), 
      ), 
    ); 
  } 
}