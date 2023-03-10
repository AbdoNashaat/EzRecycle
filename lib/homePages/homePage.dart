import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:EzRecycle/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/authentication/userAuthetication/auth.dart';
import 'HomePageList/my_drawer_header.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final User? user = Auth().currentUser;
  late String _userType;
  final List<String> pageNames = ['/forgetpasswordmailscreen','/qrScan','/updates','/aboutus','/sendfeedback','/addnewlocation','/accountinfo'];
  Future<void> signOut() async {
    await Auth().signOut();
  }
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('',style: TextStyle(color: Colors.blueGrey),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromRGBO(240, 244, 252, 1),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Material(
                    type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                    child: Column(
                      children: [
                        Text('One click & \nGet started!',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                        Ink(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400, width: 4.0),
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            //This keeps the splash effect within the circle
                            borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
                            onTap: mapList,
                            child: const Padding(
                              padding:EdgeInsets.all(20.0),
                              child: Icon(
                                Icons.recycling,
                                size: 90.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              ),
              containers('Collection Points',Icons.map,mapList,-1),
              containers('Scan QR code', Icons.qr_code, nextPage,1),
              containers('Send Feedback', Icons.feed, nextPage,4),
              addLocations(),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const MyHeaderDrawer(),
              MyDrawerList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget MyDrawerList(){
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem('Update Account Info',Icons.account_circle_outlined,nextPage,6),
          menuItem('Change password',Icons.password,nextPage,0),
          menuItem('Latest Updates!', Icons.tips_and_updates, nextPage,2),
          menuItem('About us', Icons.settings_applications_sharp, nextPage,3),
          menuItem('Sign out',Icons.logout,signOut,-1),
        ],
      ),
    );
  }

  void nextPage(int index){
    Navigator.pushNamed(context, pageNames[index]);
  }

  void closeDrawer(){
    Navigator.pop(context);
  }


  void mapList(){
    _locationServiceCheck().then((value) async {
      if(value == true) {
        final User? user = Auth().currentUser;
        _getCurrentPosition().then((position) {
          FirebaseFirestore.instance.collection('users').doc(user?.uid).update(
              {'location': GeoPoint(position.latitude, position.longitude)});
        }).whenComplete((){
            Navigator.pushNamed(context, '/maps');}
        );
      }
    });
  }

  Future<Position> _getCurrentPosition() async{
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> _locationServiceCheck() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      requestDialog('Location service disabled!','Please turn on location services');
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        requestDialog('Location Access Denied', 'Allow the app to get your current location');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever){
      requestDialog('Location services denied forever', 'We can not show you the centers around you');
      return false;
    }
    return true;
  }

  Widget containers(String text, IconData iconData,action,int index){
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(240, 244, 252, 1),width: 2)),
        child: menuItem(text, iconData, action,index)
    );
  }

  Widget menuItem(String text, IconData iconData,action,int index){
    return Material(
      child: InkWell(
        onTap: (){
          if(index == -1){
            action();
          }
          else{
            action(index);
          }
        },
        highlightColor: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(child: Icon(iconData,color: Colors.black,)),
              Expanded(
                flex: 3,
                  child: Text(text,style: const TextStyle(color: Colors.black,fontSize: 16),))
            ],
          ),
        ),
      ),
    );
  }

  Widget addLocations() {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user?.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          _userType = data['account_type'];
          if(_userType == 'admin') {
            return menuItem('Add new location', Icons.add, nextPage,5);
          }
          else{
            return const SizedBox();
          }
        }
        return const SizedBox();
      },
    );
  }

  Future requestDialog(String title, String content) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}



