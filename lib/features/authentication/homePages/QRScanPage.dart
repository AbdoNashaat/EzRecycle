import 'package:EzRecycle/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../userAuthetication/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String _qrCodeResult = "";
  final User? user = Auth().currentUser;
  void _scanQrCode() async {
    String qrCodeResult = await FlutterBarcodeScanner.scanBarcode("#00FF00", "Cancel", true, ScanMode.QR);
    setState(() {
      _qrCodeResult = qrCodeResult;
    });
    updateFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenShade,
        title: const Text("QR Code Scanner"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: greenShade,
          ),
          onPressed: _scanQrCode,
          child: const Text("Scan QR Code",style: TextStyle(fontSize: 25),),
        ),
      ),
    );
  }

  void updateFirestore() {
    if(_qrCodeResult.isNotEmpty){
    List<String> items = _qrCodeResult.split('-');
    getCurrentPoints().then((value) {
      int value1 = int.parse(items[2]);
      int value2 = int.parse(value);
      int result = value1 + value2;
      String resultString = result.toString();
      FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'points' : resultString,
      }).whenComplete(() {
        String formattedDate = DateFormat('ddMMyyyy').format(DateTime.now());
            FirebaseFirestore.instance
                .collection('wasteData')
                .doc(items[0])
                .update({
              formattedDate: FieldValue.arrayUnion([items[1]]),
            });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated',)));
        Navigator.pop(context);
      });
    });
    }
  }

  Future<String> getCurrentPoints() async {
    DocumentReference userRef = FirebaseFirestore.instance.collection("users").doc(user?.uid);
    DocumentSnapshot snapshot = await userRef.get();
    String points = snapshot["points"].toString();
    return points;
  }
}
