import 'package:flutter/material.dart';
import 'package:EzRecycle/constants/colors.dart';
import 'package:EzRecycle/constants/text_strings.dart';

class updates extends StatefulWidget {
  const updates({Key? key}) : super(key: key);

  @override
  State<updates> createState() => _updatesState();
}

class _updatesState extends State<updates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('New Updates!',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          cards('New location added!', 'A new location for plastic waste in Sakarya, Famagusta', plasticRecyclePath,'30/12/2022'),
          cards('App first launch!', 'The beta version was successfully launched on 15/12/2022', appLogoNoBackGroundPath,'15/12/2022')
        ],
      ),
    );
  }

  Widget cards(String title, String info, String imagePath,String date){
    return Padding(
      padding: EdgeInsets.all(15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 10,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 130,
                  child: Image.asset(imagePath)),
                Positioned(
                    top: 5,
                    right: 15,
                    child: Text(date,style: TextStyle(fontStyle: FontStyle.italic),))
               ]
            ),
            Text(title,style: const TextStyle(fontWeight: FontWeight.bold),),
            Text(info,style: const TextStyle(fontStyle: FontStyle.italic),textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
