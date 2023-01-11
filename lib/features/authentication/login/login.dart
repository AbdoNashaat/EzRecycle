import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_strings.dart';
import '../../internetConnection/internetNotConnected.dart';
import '../userAuthetication/auth.dart';


class loginDemo extends StatefulWidget {
  const loginDemo({Key? key}) : super(key: key);

  @override
  State<loginDemo> createState() => _loginDemoState();
}

class _loginDemoState extends State<loginDemo> {
  final formkey = GlobalKey<FormState>();

  String? errorMessage = '';

  late String _controllerEmail;
  late String _controllerPassword;

  Future<void> signInWithEmailAndPassword() async{
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail,
          password: _controllerPassword,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: greenShade,
        title: const Center(child: Text('Welcome to EzRecycle',)),
      ),
      body: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // check internet connection
              Visibility(
                  visible: Provider.of<InternetConnectionStatus>(context) ==
                      InternetConnectionStatus.disconnected,
                  child: const internetNotConnected()),
              // app logo
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                      child: Container(
                    height: 200,
                    color: backgroundGray,
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Container(
                          decoration: BoxDecoration(color: backgroundGray),
                            child: Image(image: AssetImage('assets/images/applogoNoBackGround.png'))),
                      ],
                    ),
                  ))),
              // username input
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  validator: (value) {
                    if(value![value.length-1] == " "){
                      return "Remove the space from your email";
                    }
                    else if (value.isEmpty || !RegExp(r'^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$').hasMatch(value)) {
                      return 'Not a valid Email!';
                    } else {
                      _controllerEmail = value;
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter your e-mail'),
                ),
              ),
              // password input
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  obscureText: true,
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Enter your password!';
                    }
                    else{
                    _controllerPassword = value;}
                    return null;
                  },
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter your secure password'),
                ),
              ),
              // login button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                  onPressed: () {
                    errorMessage = '';
                    if (formkey.currentState!.validate()) {
                      signInWithEmailAndPassword().whenComplete((){
                        if(wrongEmailOrPassword.contains(errorMessage)){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect email or password!')));
                        }
                        else if(errorMessage != ""){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage!)));
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
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              // spacer
              const SizedBox(
                height: 50,
              ),
              TextButton(
                child: const Text(
                  "Forgot/Reset password?",
                  style: TextStyle(color: Colors.blue, fontSize: 15,decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/forgetpasswordmailscreen');
                },
              ),
              // registration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No account?',
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  TextButton(
                    child: const Text(
                      "Sign up!",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          decoration: TextDecoration.underline),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/registrationByEmail');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
