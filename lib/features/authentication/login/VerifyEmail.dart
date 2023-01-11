import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../homePages/homePage.dart';


class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;

  @override
  void initState(){
    super.initState();
    //user needs to be created before
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();
      timer = Timer.periodic(const Duration(seconds: 3), (_)=> checkEmailVerified(),
      );
    }
  }

  @override
  void dispose(){
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async{
    // call after email verification
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if(isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    }catch(e){
      var snackBar = SnackBar(content: Text('Wait for a minute please!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      String? docId = FirebaseAuth.instance.currentUser?.uid;
      final docUser = FirebaseFirestore.instance.collection('users').doc(docId);
      docUser.update({
        'email_verification' : 'Verified',
      });
      return homePage();
    }
    else {
      return Scaffold(
        appBar: AppBar(title: const Text('Verify Email'),),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              const Text('A verification email has been sent to your email',
              style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue
                ),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  icon: const Icon(Icons.email,size: 32,),
                  label: const Text('Resend Email',style: TextStyle(fontSize: 24),)),
              const SizedBox(height: 8,),
              TextButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Cancel',style: TextStyle(fontSize: 24),),
              ),
            ],
          ),
        ),
      );
    }
  }
}
