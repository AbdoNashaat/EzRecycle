import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../constants/sizes.dart';

class ForgetPasswordMailScreen extends StatefulWidget {
  const ForgetPasswordMailScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordMailScreen> createState() => _ForgetPasswordMailScreenState();
}

class _ForgetPasswordMailScreenState extends State<ForgetPasswordMailScreen> {

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(tDefaultSize),
              child: Column(
                children: [
                  const SizedBox(height: tDefaultSize * 4,),
                  Form(
                      key: formKey,
                      child: Column(
                        children: [
                          const Icon(Icons.account_circle_sharp,size: 140,),
                          const Center(child: Text('Reset Password',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,fontFamily: 'Times New Roman'),),),
                          const SizedBox(height: 20,),
                          const Center(child: Text('Enter your email down below to receive an email to reset your password', style: TextStyle(fontSize: 15),textAlign: TextAlign.center,),),
                          TextFormField(
                            controller: emailController,
                            validator: (value){
                              if(value != null && !RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$').hasMatch(value.trim())){
                                return 'Enter a valid mail!';
                              } else{return null;}
                            }
                            ,
                            textInputAction: TextInputAction.done,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                                label: Text('E-mail'),
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.mail_outline_rounded)
                            ),
                          ),
                          const SizedBox(height: 20,),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: (){resetPassword();},
                              child: const Text('Reset Password')))
                        ],
                      ))
                ],
              ),
            ),
          )
      ),
    );
  }
  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Reset Email Sent')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
      Navigator.of(context).pop();
    }
  }
}

