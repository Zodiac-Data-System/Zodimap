import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:ui';

class Popup extends StatelessWidget {
  
  final VoidCallback runOnPressed;
  final String eventTitle;
  final String eventDescription;
  final String eventAddress;
  final String eventDate;
  final String eventTimes; 
  final String eventApprover;


  const Popup({super.key, required this.runOnPressed, required this.eventTitle, required this.eventDescription, required this.eventAddress, required this.eventDate, required this.eventTimes, required this.eventApprover});
  @override
  Widget build(BuildContext context) {
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        bottomLeft: Radius.circular(16.0),
        bottomRight: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          //width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
          width: 475,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 212, 205, 205).withOpacity(.5), // Semi-transparent background
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0),
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Text(
                  eventTitle,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ]),
              
              SizedBox(height: 8.0),
              Container(
                width: double.infinity, // fill
                height: 150.0,
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 2.50,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 5.0),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Image.asset("assets/location.png", height: 24.0, width: 24.0,), Text(" $eventAddress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal))]),
                    SizedBox(height: 5.0),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Image.asset("assets/calendar.png", height: 24.0, width: 24.0,), Text(" $eventDate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal))]),
                    SizedBox(height: 5.0),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Image.asset("assets/clock.png", height: 24.0, width: 24.0,), Text(" $eventTimes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal))]),
                    SizedBox(height: 5.0),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Image.asset("assets/person.png", height: 24.0, width: 24.0,), Text(" $eventApprover", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal))]),
                  ]
                  
                )
              ),
              SizedBox(height: 8.0),
              Text("Event Description", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(eventDescription, style: TextStyle(fontSize: 16,))
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 140.0,
                  height: 35.0,
                  child: ElevatedButton(
                    onPressed: () {
                      runOnPressed();
                    },
                    child: Text('Register'),
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
        
        
      
  }
}
