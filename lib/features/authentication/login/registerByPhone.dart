import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:EzRecycle/features/authentication/screens/widget_tree.dart';

import '../../internetConnection/internetNotConnected.dart';



class registrationByPhone extends StatefulWidget {
  const registrationByPhone({Key? key}) : super(key: key);

  @override
  State<registrationByPhone> createState() => _registrationByPhoneState();
}


class _registrationByPhoneState extends State<registrationByPhone> {
  final formkey = GlobalKey<FormState>();
  var verificationId = ''.obs;

  String? errorMessage = '';

  late String username,email,phone;
  late String sms;
  Future<void> createUserWithPhone() async{
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          autoRetrievedSmsCodeForTesting: sms,
          verificationCompleted: (credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            },
          verificationFailed: (e){
            if(e.code == 'Invalid-phone-number'){
              Get.snackbar('Error', 'The provided phone number is not valid');
            }else{
              Get.snackbar('Error', 'Something went wrong. Try again');
            }
            },
          codeSent: (verificationId,resendToken){
            this.verificationId.value = verificationId;
            },
          codeAutoRetrievalTimeout: (verificationId){
            this.verificationId.value = verificationId;
            }
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<bool> verifyOTP(String otp) async{
    var credentials = await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: this.verificationId.value, smsCode: otp));
    if(credentials.user != null){
      return true;
    }
    else{
      return false;
    }
  }
  /*Future<void> signInWithEmailAndPassword() async{
    try {
      await FirebaseAuth.instance.signInWithPhoneNumber(phone);
    } on FirebaseAuthException catch (e) {
      setState(() {});
    }
  }*/

  var otp;
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Register New Account'),
      ),
      body: Scaffold(
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children:  <Widget>[
                Visibility(
                    visible: Provider.of<InternetConnectionStatus>(context) == InternetConnectionStatus.disconnected,
                    child: const internetNotConnected()
                ),
                const Padding(padding: EdgeInsets.only(top: 60),),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty || !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)){
                        return 'Only numbers, alphabet, and _ are allowed!!';
                      }else if(value.length >= 20){
                        return 'Maximum 20 characters are allowed!';
                      }
                      else{
                        username = value;
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        hintText: 'Enter username'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty || !RegExp(r'^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$').hasMatch(value)){
                        return 'Enter a valid mail!';
                      }else{
                        email = value;
                        return null;
                      }
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid mail (abc@example.com)'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IntlPhoneField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    initialCountryCode: 'TR',
                    onChanged: (number){
                      phone = number.completeNumber;
                    },
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      errorMessage = '';
                      if(formkey.currentState!.validate() && Provider.of<InternetConnectionStatus>(context, listen: false) == InternetConnectionStatus.connected){
                        createUserWithPhone().whenComplete((){
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40))),
                              builder: (context) => Column(
                                children: [
                                  TextFormField(
                                    obscureText: false,
                                    validator: (value){
                                      if(value!.isEmpty){
                                        return 'Enter your password!';
                                      }
                                      else{
                                        otp = value;
                                        return null;}
                                    },
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'OTP',
                                        hintText: 'Enter your OTP'),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        var isVerified = verifyOTP(otp);
                                        if(await isVerified){
                                          Get.offAll(WidgetTree());
                                        }else{
                                          Get.back();
                                        }
                                        },
                                      child: Text('Click to submit the otp'))
                                ],
                              )
                          );
                          }

                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 15.0,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text('Register', style: TextStyle(fontSize: 20),),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future createUser({required email, required phone, required username}) async{
    final docUser = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
    final json = {
      'username' : username,
      'email' : email,
      'phone_number' : phone,
      'points' : 0,
      'email_verification' : 'Not verified',
      'signing_method' : 'phone'
    };
    await docUser.set(json);
  }
}