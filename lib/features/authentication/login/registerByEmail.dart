import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:EzRecycle/features/authentication/screens/widget_tree.dart';

import '../../../constants/colors.dart';
import '../internetConnection/internetNotConnected.dart';
import '../userAuthetication/auth.dart';


class registrationByEmail extends StatefulWidget {
  const registrationByEmail({Key? key}) : super(key: key);

  @override
  State<registrationByEmail> createState() => _registrationByEmailState();
}


class _registrationByEmailState extends State<registrationByEmail> {
  final formkey = GlobalKey<FormState>();

  late String _controllerEmail;
  late String _controllerPassword;
  String? errorMessage = '';

  late String passwordCheck;
  late String username,email,password,phone;



  Future<void> createUserWithEmailAndPassword() async{
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail,
        password: _controllerPassword,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> signInWithEmailAndPassword() async{
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail,
        password: _controllerPassword,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: greenShade,
        title: const Text('Register New Account'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          backgroundColor: backgroundGray,
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
                          if(value!.isEmpty){
                            return 'Required Field!';
                          }
                          else if(!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!)){
                            return 'Only numbers, alphabet, and _ are allowed!!';
                          }else if(value.length > 15){
                            return 'Maximum 15 characters are allowed!';
                          }
                          else{
                            username = value;
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            hintText: 'Enter username'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        validator: (value){
                          if(value!.isEmpty){
                            return 'Required Field!';
                          }
                          else if(!RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$').hasMatch(value!)){
                            return 'Enter a valid mail!';
                          }else{
                            email = value;
                            _controllerEmail = value;
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            hintText: 'Enter valid mail (abc@example.com)'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        obscureText: true,
                        validator: (value){
                          if(value!.isEmpty){
                            return 'Required Field!';
                          }
                          else if(value!.length < 8){
                            return 'Password must be longer than 8 characters!';
                          }else if(value!.length > 30){
                            return 'The Max number of characters is 30!';
                          }else{
                            passwordCheck = value!;
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: 'Enter your secure password'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        validator: (value){
                          if(value != passwordCheck ){
                            return 'Please enter the same password!';
                          }else{
                            password = value!;
                            _controllerPassword = value!;
                            return null;
                          }
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            labelText: 'Re-enter Password',
                            hintText: 'Re-enter your secure password'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: IntlPhoneField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Mobile Number',
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
                          if(formkey.currentState!.validate() &&
                              Provider.of<InternetConnectionStatus>(context, listen: false) == InternetConnectionStatus.connected){
                            createUserWithEmailAndPassword().whenComplete((){
                              if(errorMessage != ''){
                                var snackBar = SnackBar(content: Text(errorMessage!));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                              else{
                                createUser(email: email, phone: phone, username: username);
                                _controllerEmail = email;
                                _controllerPassword = password;
                                Navigator.pop(context);
                                //signInWithEmailAndPassword();
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenShade,
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
      'signing_method' : 'email',
      'account_type' : 'user'
    };
    await docUser.set(json);
  }
}
