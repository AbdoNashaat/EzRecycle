import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/authentication/userAuthetication/auth.dart';
import 'directions_model.dart';
import 'directions_repository.dart';

class mapToDestination extends StatefulWidget {
  final double locationLongitude;
  final double locationLatitude;

  const mapToDestination(
      {Key? key, required this.locationLongitude, required this.locationLatitude})
      : super(key: key);

  @override
  State<mapToDestination> createState() =>
      _mapToDestinationState(destinationLng: locationLongitude, destinationLat: locationLatitude);
}

class _mapToDestinationState extends State<mapToDestination> {
  final User? user = Auth().currentUser;
  double destinationLng;
  double destinationLat;

  _mapToDestinationState(
      {required this.destinationLng, required this.destinationLat});

  late Position _currentPosition ;
  Set<Marker> _markers = Set();
  late Directions _info;

  Future<Directions> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = position;
    _markers.add(Marker(
      markerId: const MarkerId('current_location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(Checkbox.width),
      position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      infoWindow: const InfoWindow(
        title: 'Current Location',
      ),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('destination_location'),
      position: LatLng(destinationLat, destinationLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue,),
      infoWindow: const InfoWindow(title: 'Destination',),
    ),);
    LatLng origin = LatLng(position.latitude, position.longitude);
    LatLng destination = LatLng(destinationLat, destinationLng);
    _info = (await DirectionsRepository().getDirections(
        origin: origin, destination: destination))!;
    return _info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Map'),),
      body: FutureBuilder(
        future: _getCurrentLocation(),
        builder: ( context, snapshot) {
          if(snapshot.hasData){
            return Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                    zoom: 16.0,
                  ),
                  markers: _markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('overview_polyline'),
                      color: Colors.red,
                      width: 5,
                      points: _info.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                    )
                  },
                ),
                Positioned(
                    top: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12
                      ),
                      decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6
                            )
                          ]
                      ),
                      child: Row(
                        children: [
                          Text('${_info.totalDistance}, ${_info.totalDuration}', style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                          const Icon(Icons.directions_car_rounded),
                        ],
                      ),
                    )),
                Positioned(
                  bottom: 15,
                  left: 5,
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        width: 200,
                        color: Colors.transparent,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                            children: [
                              const TextSpan(text: 'Tap '),
                              TextSpan(text: 'Destination', style: TextStyle(color: Colors.indigo[700])),
                              const TextSpan(text: ', Then click the right arrow to use Google Maps'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
          );
          }
          else if(snapshot.hasError){
            return const Center(child: Text("Error!"),);
          }
          else{
            return  const Center(child: CircularProgressIndicator(),);
          }
        },
      )
    );
  }
}