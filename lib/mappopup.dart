import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:ui';

class Popup extends StatelessWidget {
  
  final VoidCallback runOnPressed;
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime; 

  const Popup({super.key, required this.runOnPressed, required this.eventTitle, required this.eventDescription, required this.eventDate, required this.eventStartTime, required this.eventEndTime});
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
          width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // Semi-transparent background
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
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: NetworkImage('https://banner2.cleanpng.com/20180810/eji/adab626c847044a992aa49c9aaf003bb.webp'),)
                ,Text(
                  eventTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ]),
              
              SizedBox(height: 8.0),
              Text(
                "Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              
              ),
              SizedBox(height: 0.0),
              Container(
                //width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                height: 150.0,
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Text("Start Time: $eventStartTime"),
              Text("End Time: $eventEndTime"),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  runOnPressed();
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
        
        
      
  }
}
