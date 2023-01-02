import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/colors.dart';
import '../authentication/userAuthetication/auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key}) : super(key: key);

  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  final User? user = Auth().currentUser;

  Widget _UserInfo(){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user?.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<
              String,
              dynamic>;
          return Column(
            children: [
              Text('${data['username']}',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),),
              Text('${data['email']}',style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 15),),
            ],
          );
        }
        return const Text("loading");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGray,
      width: double.infinity,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle,size: 150,),
          _UserInfo()
        ],
      ),
    );
  }
}
