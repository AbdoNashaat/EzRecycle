import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EzRecycle/features/authentication/forget_password/forget_password_mail/forget_password_mail.dart';
import 'package:EzRecycle/features/authentication/homePages/accountinfo.dart';
import 'package:EzRecycle/features/authentication/homePages/add_new_locations.dart';
import 'package:EzRecycle/features/authentication/login/registerByEmail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:EzRecycle/features/authentication/login/registerByPhone.dart';
import 'package:EzRecycle/features/authentication/screens/widget_tree.dart';
import 'features/authentication/forget_password/forget_password_phone/forget_password_phone.dart';
import 'features/authentication/homePages/QRScanPage.dart';
import 'features/authentication/homePages/aboutUs.dart';
import 'features/authentication/homePages/sendFeedBack.dart';
import 'features/authentication/homePages/updates.dart';
import 'features/maps/theMap.dart';
import 'firebase_options.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return StreamProvider<InternetConnectionStatus>(
      initialData: InternetConnectionStatus.connected,
      create: (_){
        return InternetConnectionChecker().onStatusChange;
      },
      child: MaterialApp(
        home: const WidgetTree(),
        routes: {
          '/registrationByEmail' : (context) => const registrationByEmail(),
          '/registrationByPhone' : (context) => const registrationByPhone(),
          '/forgetpasswordmailscreen' : (context) => const ForgetPasswordMailScreen(),
          '/forgetpasswordphonescreen' : (context) => const ForgetPasswordPhoneScreen(),
          '/accountinfo' : (context) => accountinfo(),
          '/maps' : (context) => const mapList(),
          '/aboutus' : (context) => const aboutUs(),
          '/sendfeedback' : (context) => const sendFeedBack(),
          '/updates' : (context) => const updates(),
          '/addnewlocation' : (context) =>  AddPlacePage(),
          '/qrScan' : (context) => QRScanPage(),
        },
      ),
    );
  }
}


