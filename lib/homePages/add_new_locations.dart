import 'package:EzRecycle/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/hard_coded_locations.dart';
import '../features/authentication/userAuthetication/auth.dart';

class AddPlacePage extends StatefulWidget {
  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  // Text controllers for the place title and info fields
  final User? user = Auth().currentUser;
  final _picker = ImagePicker.platform;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _QRController = TextEditingController();
  Set<Marker> _markers = Set();
  // Latitude and longitude of the selected location on the map
  double _latitude = notDefinedLocation;
  double _longitude = notDefinedLocation;
  //FocusNode myFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _infoController.dispose();
    _QRController.dispose();
    //...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: greenShade,
        title: const Text('New Location'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Place title field
                  TextField(
                    //focusNode: myFocusNode,
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'add location title',
                      labelText: 'New Location Title'
                    ),
                  ),
                  const SizedBox(height: 15,),
                  // Place info field
                  TextField(
                    controller: _infoController,
                    decoration: const InputDecoration(
                      labelText: 'Waste type Info',
                      hintText: 'add waste types'
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextField(
                    //focusNode: myFocusNode,
                    controller: _QRController,
                    decoration: const InputDecoration(
                        hintText: 'QR settings (Yes OR No)',
                        labelText: 'QR code'
                    ),
                  ),
                  const SizedBox(height: 15,),
                  // Map to select the location of the place
                  SizedBox(
                    height: 300,
                    child: GestureDetector(
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(centerOfAddLocationsMapLat, centerOfAddLocationsMapLng),
                          zoom: 9,
                        ),
                        onTap: (LatLng coordinates) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          //myFocusNode.unfocus();
                          // Update the latitude and longitude when the map is tapped
                          setState(() {
                            _markers.clear();
                            _markers.add(Marker(
                              markerId: MarkerId(coordinates.toString()),
                              position: coordinates,
                            ));
                            _latitude = coordinates.latitude;
                            _longitude = coordinates.longitude;
                          });
                        },
                        markers: _markers,
                      ),
                    ),
                  ),

                  // Button to submit the place data to FireStore
                  ElevatedButton(
                    onPressed: () async {
                      if(_latitude == notDefinedLocation || _longitude == notDefinedLocation ){
                       dialogBox('Please select location', 'Select the location by clicking on the google map shown');
                      }else{
                        // Get the values from the text controllers
                        String title = _titleController.text;
                        String info = _infoController.text;
                        if(title.isEmpty || info.isEmpty){
                          dialogBox('Empty fields!','The location title or waste type is empty');
                        }else if(!['yes','no'].contains(_QRController.text.toLowerCase())){
                          dialogBox('QR invalid!','The QR field could be only yes or no');
                        } else{
                        String? uid = user?.uid;
                        String optionForQR = _QRController.text.toLowerCase() == "yes" ? "Supported" : "Not supported";
                        String adminEmail= user?.email ?? 'Could not get email, user token is ${uid!}';
                        // Create a new document in the 'places' collection
                        DocumentReference docRef = FirebaseFirestore.instance.collection("locations").doc();
                        String docId = docRef.id;
                        await docRef.set({
                          'title': title,
                          'TypeOfWaste': info,
                          'location': GeoPoint(_latitude, _longitude),
                          'admin_email' : adminEmail,
                          'QR option' : optionForQR,
                          'timestamp' : FieldValue.serverTimestamp()
                        }).whenComplete(() {
                          FirebaseFirestore.instance.collection("wasteData").doc(docId).set({});
                        });
                        dialogBox('successfully submitted!', 'The new location has been added to the database');
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future dialogBox(String title,contents) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(title),
          content: Text(contents),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if(title == 'successfully submitted!'){
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
