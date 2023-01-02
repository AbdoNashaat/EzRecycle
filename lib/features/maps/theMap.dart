import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:EzRecycle/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:EzRecycle/features/maps/mapToDestination.dart';
import '../authentication/userAuthetication/auth.dart';
import 'directions_model.dart';
import 'directions_repository.dart';

class mapList extends StatefulWidget {
  const mapList({Key? key}) : super(key: key);

  @override
  State<mapList> createState() => _mapListState();
}

class _mapListState extends State<mapList> {

    String _searchQuery = '';
    final User? user = Auth().currentUser;
    late List<DocumentSnapshot> documents;
    late Icon qrSupport;
    late List<DocumentSnapshot> _filteredLocations;
    Stream<List<DocumentSnapshot>> getPlaces() {
      return FirebaseFirestore.instance.collection('locations').snapshots().map((snapshot) => snapshot.docs);
    }
    late List<String?> distancesList = [];
    Future<String> locationString(documents,index) async {
      GeoPoint point= documents[index]['location'];
      DocumentSnapshot snapshot= await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      var value = snapshot.get('location');
      LatLng origin = LatLng(value.latitude, value.longitude);
      LatLng destination = LatLng(point.latitude, point.longitude);
      final directions = await DirectionsRepository().getDirections(
          origin: origin, destination: destination);
      return directions?.totalDistance as String;
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: greenShade,
          title: TextField(
            //controller:  _textController,
            onChanged: (value) {
              _searchQuery = value;
              setState(() {
                 _searchQuery = value;
                _filteredLocations = documents.where((location) => location['title'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search Nearby Locations',
              border: InputBorder.none,
            ),
          ),
        ),
        body: StreamBuilder(
          stream: getPlaces(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              documents = snapshot.requireData;
              _filteredLocations = documents.where(
                      (location) => location['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          location['TypeOfWaste'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
              if(_filteredLocations.isEmpty){
                return AlertDialog(
                  title: const Text('Unavailable'),
                  content: const Text('Sorry! This type does not have any bins available'),
                  backgroundColor: alertDialogColors,
                  actions: <Widget>[
                    ElevatedButtons('Give Feedback with waste type',Colors.green,'/sendfeedback'),
                    ElevatedButtons('Discard',Colors.black,'/maps'),
                  ],
                );
              }
              return ListView.separated(
                itemCount: _filteredLocations.length,
                itemBuilder: (context, index) {
                  //locationString(documents, index);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (_) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: ListTile(
                      leading:  const Icon(Icons.recycling,color: Colors.green,),
                      title: Text(_filteredLocations[index]['title']),
                      subtitle: Text(_filteredLocations[index]['TypeOfWaste']),
                      onTap: (){
                        if(_filteredLocations[index]['QR option'] == 'Supported'){
                        GeoPoint point = _filteredLocations[index]['location'];
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => mapToDestination(locationLongitude: point.longitude,locationLatitude: point.latitude)));
                        } else{
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text('This location does not offer points',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                backgroundColor: alertDialogColors,
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: const Text("Discard"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      //Navigator.pushNamed(context, '/maps');
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Text("Continue"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      GeoPoint point = _filteredLocations[index]['location'];
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => mapToDestination(locationLongitude: point.longitude,locationLatitude: point.latitude)));
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      trailing: FutureBuilder<String>(
                        future: locationString(_filteredLocations, index),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            distancesList.add(snapshot.data );
                            return Text(snapshot.data ?? '');
                          } else if (snapshot.hasError) {
                            return const Text('--');
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    }

    Widget ElevatedButtons(String title,textColor,String nextPage){
      return ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, nextPage);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            //onPrimary: Colors.black,
            elevation: 0
        ),
        child:  Center(child: Text(title,style: TextStyle(color: textColor,fontSize: 15,fontWeight: FontWeight.bold),)),
      );
    }


}
