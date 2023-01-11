import 'package:flutter/material.dart';
import 'package:EzRecycle/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../features/authentication/userAuthetication/auth.dart';
class sendFeedBack extends StatefulWidget {
  const sendFeedBack({Key? key}) : super(key: key);

  @override
  State<sendFeedBack> createState() => _sendFeedBackState();
}

class _sendFeedBackState extends State<sendFeedBack> {
  String feedback = '';
  final User? user = Auth().currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(title: const Text('Send Feedback'),backgroundColor: greenShade),
      body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(20,20,20,40),
                  child: Image(image: AssetImage('assets/images/feedback.png'),height: 200,)),
              Padding(
                padding: EdgeInsets.all(15),
                child: TextField(
                    maxLength: 100,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Enter your feedback here',
                      contentPadding: EdgeInsets.all(15.0),
                      filled: true,
                      alignLabelWithHint: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder()
                    ),
                    onChanged: (value){
                      feedback = value;
                    }
                  ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey
                ),
                child: const Text('Submit'),
                onPressed: () {
                  submitFeedback();
                },
              ),
            ],
          ),
        ),
    );
  }
  void pop(){
    Navigator.pop(context);
  }

  void submitFeedback() async{
    if(feedback.isEmpty){
      dialogBox('Empty Feedback!',false,alertDialogColors,Colors.red);
    }
    else if (feedback.contains("--") || feedback.contains(";") || feedback.contains("/*")) {
      dialogBox('Please remove special characters from your feedback!', false,alertDialogColors,Colors.red);
    }
    else{
      dialogBox('Feedback submitted, \nThank you!',true,alertDialogColors,Colors.green);
        FirebaseFirestore.instance.collection('feedback').add({
          'user feedback': feedback,
          'email' : user?.email,
          'timestamp' : FieldValue.serverTimestamp()
        });
    }
  }

  void dialogBox(String message,bool condition,Color color,Color textColor) async {
     showDialog(
        context: context,
        builder: (context) {
      return AlertDialog(
        content: Text(message,style: TextStyle(fontWeight: FontWeight.bold,color: textColor),),
        backgroundColor: color,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            child: Text("OK"),
            onPressed: () {
              pop();
              if(condition) {
                pop();
              }
            },
          ),
        ],
      );
    },
    );
  }

}
