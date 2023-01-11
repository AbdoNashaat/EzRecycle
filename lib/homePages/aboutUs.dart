import 'package:flutter/material.dart';
import 'package:EzRecycle/constants/colors.dart';

import '../../../constants/text_strings.dart';

class aboutUs extends StatefulWidget {
  const aboutUs({Key? key}) : super(key: key);

  @override
  State<aboutUs> createState() => _aboutUsState();
}

class _aboutUsState extends State<aboutUs> {

  late String studentnumberOrDuty;
  final List<bool> _showInfo = [false,false,false,false,false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              const SizedBox(height: 10,),
              const Center(child: Text('Team members',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w100,fontSize: 30),)),
              containers(abdelghafaar_info),
              containers(ramazan_info),
              containers(alper_info),
              containers(ahmed_info),
              const Center(child: Text('Our Supervisor',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w100,fontSize: 30),)),
              containers(supervisor_info),
            ],
          )
      ),
    );
  }

  Widget menuItem(List info){
    String secondField = 'Student Number';
    if(info[1] ==4 ) secondField = 'Duty';
    return Material(
      child: InkWell(
        onTap: (){
          setState(() {
            _showInfo[info[1]] = !_showInfo[info[1]];
          });
        },
        highlightColor: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Icon(Icons.person_sharp,color: Colors.black,)),
                  Expanded(
                      flex: 9,
                      child: Center(child: Text(info[0],style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.start,)))
                ],
              ),
              if(_showInfo[info[1]])
                Column(
                  children: [
                    Text(secondField+': '+info[2],style: const TextStyle(fontStyle: FontStyle.italic),),
                    Text('Email: '+info[3],style: const TextStyle(fontStyle: FontStyle.italic),),
                    Text('Department: '+info[4],style: const TextStyle(fontStyle: FontStyle.italic),)
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget containers(List info){
    return Container(
        decoration: BoxDecoration(border: Border.all(color: backgroundGray,width: 4)),
        child: menuItem( info)
    );
  }

}
