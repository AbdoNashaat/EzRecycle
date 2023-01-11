import 'package:flutter/material.dart';
import 'package:EzRecycle/features/authentication/login/login.dart';
import '../login/VerifyEmail.dart';
import '../userAuthetication/auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context,snapshot) {
        if(snapshot.hasData){
          return VerifyEmailPage();
        }
        else{
          return const loginDemo();
        }
      },
    );
  }
}
