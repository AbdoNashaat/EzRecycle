import 'package:EzRecycle/maps/infoAboutLocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:EzRecycle/features/authentication/forget_password/forget_password_mail/forget_password_mail.dart';
import 'package:EzRecycle/features/authentication/login/registerByEmail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:EzRecycle/features/authentication/login/registerByPhone.dart';
import 'package:EzRecycle/features/authentication/screens/widget_tree.dart';
import 'features/authentication/forget_password/forget_password_phone/forget_password_phone.dart';
import 'firebase_options.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'homePages/QRScanPage.dart';
import 'homePages/aboutUs.dart';
import 'homePages/accountinfo.dart';
import 'homePages/add_new_locations.dart';
import 'homePages/sendFeedBack.dart';
import 'homePages/updates.dart';
import 'maps/theMap.dart';

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
          '/accountinfo' : (context) => const accountinfo(),
          '/maps' : (context) => const mapList(),
          '/aboutus' : (context) => const aboutUs(),
          '/sendfeedback' : (context) => const sendFeedBack(),
          '/updates' : (context) => const updates(),
          '/addnewlocation' : (context) =>  AddPlacePage(),
          '/qrScan' : (context) => const QRScanPage(),
          '/infoAboutLocation' : (context) => const InfoAboutLocation(),
        },
      ),
    );
  }
}


