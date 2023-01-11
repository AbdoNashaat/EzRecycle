import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:EzRecycle/constants/colors.dart';
import '../../../constants/text_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/authentication/userAuthetication/auth.dart';
import '../features/internetConnection/internetNotConnected.dart';

class accountinfo extends StatefulWidget {
  const accountinfo({Key? key}) : super(key: key);

  @override
  State<accountinfo> createState() => _accountinfoState();
}

class _accountinfoState extends State<accountinfo> {
  final formKey = GlobalKey<FormState>();
  final User? user = Auth().currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  late String _usernameController;
  late String _emailController;
  bool emailChanged = false;
  bool usernameChanged = false;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: backgroundGray,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: greenShade,
        title: const Text('Account Information'),),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                  visible: Provider.of<InternetConnectionStatus>(context) == InternetConnectionStatus.disconnected,
                  child: const internetNotConnected()
              ),
              warning(),

              infoAboveInputs('Email','email',0),
              inputTextFields('Email',r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$',0),
              infoAboveInputs('Username','username',1),
              inputTextFields('Username',r'^[a-zA-Z0-9_]+$',1),
              infoAboveInputs('Phone Number','phone_number',2),
              inputTextFields('Phone Number','phone_number',2),
              points('Points','points'),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey
                  ),
                  child: const Text('Update'),
                  onPressed: () {
                    if(formKey.currentState!.validate() && Provider.of<InternetConnectionStatus>(context, listen: false) == InternetConnectionStatus.connected){
                      if(emailChanged && usernameChanged) {
                        FirebaseAuth.instance.currentUser?.updateEmail(_emailController)
                            .then((value) {
                          FirebaseFirestore.instance.collection('users').doc(
                              user?.uid).update({
                            'username': _usernameController,
                            'email': _emailController,
                            'email_verification': 'Not verified'
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated',)));
                          Navigator.pop(context);
                          Auth().signOut();
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString(),)));
                        });
                      }
                      else if(emailChanged){
                        FirebaseAuth.instance.currentUser?.updateEmail(_emailController).then((value){
                          FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
                            'email' : _emailController,
                            'email_verification': 'Not verified'
                              }).whenComplete(() {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated! Check re-login in using the new email',)));
                              Navigator.pop(context);
                              FirebaseAuth.instance.signOut();
                          });
                        }).catchError((error){
                          errorMessage = error.toString();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                        }).whenComplete((){
                        });

                      }
                      else if(usernameChanged){
                        FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
                          'username' : _usernameController,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated',)));
                        setState(() {});
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget warning() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
      child: const Text(warningText,style: TextStyle(fontSize: 20,color: Colors.red),),
    );
  }

  Widget infoAboveInputs(String text, String field,int index) {
    return FutureBuilder(
        future:users.doc(user?.uid).get(),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            Map<String, dynamic> data = snapshot.data!.data() as Map<
                String,
                dynamic>;
            return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text('Old $text: ${data[field]}',style: const TextStyle(fontSize: 15),));
          }
          else{
            return const CircularProgressIndicator();
          }
        });
  }

  Widget points(String title, String documentElement){
    return FutureBuilder(
        future:users.doc(user?.uid).get(),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            Map<String, dynamic> data = snapshot.data!.data() as Map<
                String,
                dynamic>;
            return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text('${data[documentElement]}  $title',style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),));
          }
          else{
            return const CircularProgressIndicator();
          }
        });
  }

  Widget inputTextFields(field, String regex, int index) {
    bool allowed = true;
    String inputLabelText = 'New $field';
    if(index == 2){
      allowed = false;
      inputLabelText = 'Phone Number disabled';
    }
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            enabled: allowed,
            validator: (value){
              value ??= '';
              if(value.isNotEmpty){
                if(value[value.length-1]==" "){
                  return 'Remove the last space';
                }else if(index == 0 && !RegExp(regex).hasMatch(value)){
                  return 'Enter a valid mail';
                }else if(index == 1 && !RegExp(regex).hasMatch(value)){
                  return 'Enter a valid username';
                }else if(index == 1 && value.length>15){
                  return 'Maximum 15 characters allowed';
                }if(index == 0){
                  emailChanged = true;
                  _emailController = value;
                }if(index == 1){
                  usernameChanged = true;
                  _usernameController = value;
                }
              }
              else{
                if(index == 0){
                  _emailController = '';
                  emailChanged = false;
                }else if(index == 1){
                  _usernameController = '';
                  usernameChanged = false;
                }
              }
              return null;
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
                labelText: inputLabelText,
                hintText: 'Enter new $field'),
          )
        ],
      ),
    );
  }

}
