import 'package:flutter/material.dart';

import '../../../../constants/sizes.dart';

class ForgetPasswordPhoneScreen extends StatelessWidget {
  const ForgetPasswordPhoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(tDefaultSize),
              child: Column(
                children: [
                  const SizedBox(height: tDefaultSize * 4,),
                  Form(
                      child: Column(
                        children: [
                          const Icon(Icons.account_circle_sharp,size: 140,),
                          const Center(child: Text('Forget Password',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,fontFamily: 'Times New Roman'),),),
                          const SizedBox(height: 20,),
                          const Center(child: Text('Enter your phone number down below to receive a message', style: TextStyle(fontSize: 15),textAlign: TextAlign.center,),),
                          TextFormField(
                            decoration: const InputDecoration(
                                label: Text('Phone number'),
                                hintText: 'Enter your phone number',
                                prefixIcon: Icon(Icons.message)
                            ),
                          ),
                          const SizedBox(height: 20,),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: (){},
                                  child: const Text('Next'))
                          )
                        ],
                      ))
                ],
              ),
            ),
          )
      ),
    );
  }
}