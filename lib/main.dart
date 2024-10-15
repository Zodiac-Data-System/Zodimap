import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
//import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider';
import 'dart:ui';

import 'package:zodimap/mappopup.dart'; // Import the dart:ui library for ImageFilter

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//from ethan
class CustomButton extends StatelessWidget {
  final String platform;
  final VoidCallback onPressed;
  const CustomButton(
      {super.key, required this.platform, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Press the below button to follow me on $platform"),
      ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Pressed Follow on $platform button"),
              duration: const Duration(seconds: 1),
            ),
          );
          onPressed();
        },
        child: Text("Follow on $platform"),
      )
    ]));
  }
}

// class MarkerWithTooltip extends StatefulWidget {
//   final Widget child;
//   final String tooltip;
//   final Function onTap;

//   MarkerWithTooltip({@required this.child, this.tooltip, this.onTap});

//   @override
//   _MapMarkerState createState() => _MapMarkerState();
// }

// class _MapMarkerState extends State<MarkerWithTooltip> {
//   final key = new GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//         onTap: () {
//           final dynamic tooltip = key.currentState;
//           tooltip.ensureTooltipVisible();
//           widget.onTap();
//         },
//         child: Tooltip(
//           key: key,
//           message: widget.tooltip,
//           child: widget.child,
//         ));
//   }
// }//credit: https://github.com/fleaflet/flutter_map/issues/184

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
  //State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final int _counter = 0;
  LatLng _initialPosition = LatLng(34.036, -117.850); // Default to London
  bool _locationFetched = false;
  Location location = Location();
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;
  bool _isEventVisible = false;
  String _eventTitle = '';
  String _eventDescription = '';
  String _eventAddress = ' ';
  String _eventDate = ' ';
  String _eventTimes = ' ';
  String _eventApprover = ' ';
  late Animation<double> _animation;
  late MapController _mapController;
  double currentZoom = 9.2;
  LatLng currentCenter = LatLng(51.5, -0.09);

  late final _animatedMapController = AnimatedMapController(vsync: this);
  bool _useTransformer = true;
  int _lastMovedToMarkerIndex = -1;
  static const _useTransformerId = 'useTransformerId';

  List<Marker> markers = [];

  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOutExpo,
    ));
    _mapController = MapController();
    _animation = CurvedAnimation(
      parent: _controller as AnimationController,
      curve: Curves.easeInOutCubicEmphasized,
    );
//    _animation = Tween<double>(begin: 0, end: 1).animate(_controller as Animation<double>)
//      ..addListener(() {
//        setState(() {});
//      });
    _getCurrentLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _initialPosition =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
    });
    final int markerCount =
        Random().nextInt(10) + 5; // Random number of markers between 1 and 10
    markers = _generateRandomMarkers(markerCount);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check for location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    locationData = await location.getLocation();
    setState(() {
      _initialPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _locationFetched = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _showMarkerInfo(String title, String description, String address, String date, String times, String approver) {
    setState(() {
      _eventTitle = title;
      _eventDescription = description;
      _eventAddress = address;
      _eventDate = date;
      _eventTimes = times;
      _eventApprover = approver;
      _isEventVisible = true;
    });
    _controller?.forward();
  }

  void _hideMarkerInfo() {
    _controller?.reverse().then((_) {
      setState(() {
        _isEventVisible = false;
      });
    });
  }

  void _zoomIn() {
    currentZoom = currentZoom + 1;
    _animatedMapController.animateTo(
      curve: Curves.easeInOut,
      customId: _useTransformer ? _useTransformerId : null,
      dest: currentCenter,
      zoom: currentZoom,
      duration: Duration(milliseconds: 500),
    );
    //_mapController.move(currentCenter, currentZoom);
  }

  void _zoomOut() {
    currentZoom = currentZoom - 1;
    _animatedMapController.animateTo(
      curve: Curves.easeInOut,
      customId: _useTransformer ? _useTransformerId : null,
      dest: currentCenter,
      zoom: currentZoom,
      duration: Duration(milliseconds: 500),
    );
    //_mapController.move(currentCenter, currentZoom);
  }

  void _resetOrientation() {
    currentZoom = 9.2;
    currentCenter = LatLng(51.5, -0.09);
    _mapController.move(currentCenter, currentZoom);
  }

  void _updateCurrentCenter(LatLng position) {
    setState(() {
      currentCenter = position;
    });
  }

  List<Marker> _generateRandomMarkers(int count) {
    final Random random = Random();
    final List<Marker> markers = [];

    for (int i = 0; i < 6; i++) {
      bool posneg = random.nextBool();
      double lat = 34.036;
      double lng = -117.850;

      if (posneg) {
        lat =
            34.036 + random.nextDouble() * 0.02; // Latitude range around walnut
        lng =
            -117.850 + random.nextDouble() * 0.035; // Longitude range around walnut
      } else {
        lat =
          34.036 - random.nextDouble() * 0.02; // Latitude range around walnut
        lng =
          -117.850 - random.nextDouble() * 0.035; // Longitude range around walnut
      }

      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMarker = markers[i];
                _controller?.reset();
                _controller?.forward();
              });
              print("Marker tapped");
              _animatedMapController.animateTo(
                dest: LatLng(lat, lng),
                zoom: 15.0,
                duration: Duration(milliseconds: 500),
              );
              currentZoom = 15.0;
              _showMarkerInfo("Marker $i", "This is marker $i.", "123 Sesame Street", "October 13th, 2024", "2:00PM-4:00PM", "Derek Chang" );
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  //scale: 1 + _animation.value * 0.5, // Scale the marker
                  scale: _selectedMarker == markers[i]
                      ? 1 + _animation.value * 0.5
                      : 1,
                  child: child,
                  alignment: Alignment.bottomCenter,
                );
              },
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        ),
      );
    }
    markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(34.03681014225593, -117.85032157566803),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMarker = markers[6];
                _controller?.reset();
                _controller?.forward();
              });
              print("Marker tapped");
              _animatedMapController.animateTo(
                dest: LatLng(34.03681014225593, -117.85032157566803),
                zoom: 15.0,
                duration: Duration(milliseconds: 500),
              );
              currentZoom = 15.0;
              _showMarkerInfo("Application Developement", 
              "Join the Zodiac App Development Team for a progress update on ZodiApp, the volunteer-focused extension of their Zodiac Data Management System. The team will review recent project milestones, present a demo of new app features, and discuss challenges encountered during the development process. Future plans and upcoming goals will also be outlined, followed by an open Q&A session for feedback and insights.", 
              "20752 E Walnut Canyon Rd, Walnut, 91789", "October 12th, 2024", "9:30AM-12:30PM", "Fiona Xu" );
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  //scale: 1 + _animation.value * 0.5, // Scale the marker
                  scale: _selectedMarker == markers[6]
                      ? 1 + _animation.value * 0.5
                      : 1,
                  child: child,
                  alignment: Alignment.bottomCenter,
                );
              },
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        ),
      );
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(34.02215, -117.8507),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMarker = markers[7];
                _controller?.reset();
                _controller?.forward();
              });
              print("Marker tapped");
              _animatedMapController.animateTo(
                dest: LatLng(34.02215, -117.8507),
                zoom: 15.0,
                duration: Duration(milliseconds: 500),
              );
              currentZoom = 15.0;
              _showMarkerInfo("Clothing Drive", 
              "Join us for the annual Fall Clothing Drive, where we’ll be collecting gently used clothing items for local shelters in need. We accept coats, sweaters, gloves, scarves, and other winter essentials to help provide warmth and comfort to individuals facing difficult times. All donations will go directly to shelters serving families and individuals in the community. Drop-off stations will be available throughout the event, and volunteers will be on hand to assist.", 
              "400 Pierre Rd, Walnut, 91789", "October 23rd, 2024", "1:30PM-3:30PM", "John Yang" );
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  //scale: 1 + _animation.value * 0.5, // Scale the marker
                  scale: _selectedMarker == markers[7]
                      ? 1 + _animation.value * 0.5
                      : 1,
                  child: child,
                  alignment: Alignment.bottomCenter,
                );
              },
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        ),
      );
    return markers;
  }

  @override
  Widget build(BuildContext context) {
/*    
    final markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(34.036, -117.850), // coordinates of
        child: GestureDetector(
          onTap: () {
            print("Marker tapped");
            _animatedMapController.animateTo(
              dest: LatLng(34.036, -117.850),
              zoom: 15.0,
              customId: _useTransformer ? _useTransformerId : null,
              duration: Duration(milliseconds: 500),
            );
            currentZoom = 15.0;
            _showMarkerInfo("Marker 2", "This is marker 2.");
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + _animation.value * 0.5, // Scale the marker
                child: child,
                alignment: Alignment.bottomCenter,
              );
            },
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(34.036, -119.850), // coordinates of
        child: Icon(Icons.location_on,
            color: const Color.fromRGBO(54, 114, 244, 1), size: 40),
      ),
      // Add more markers here
    ];
    */

    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(kToolbarHeight),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       color: Colors.transparent,
      //     ),
      //     child: ClipRect(
      //       child: BackdropFilter(
      //         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      //         child: AppBar(
      //           title: Text('ZodiMap'),
      //           centerTitle: false,
      //           backgroundColor:
      //               Colors.grey.withOpacity(0.5), // Semi-transparent background
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: currentZoom,
              interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.scrollWheelZoom),
              onMapEvent: (mapEvent) {
                if (mapEvent is MapEventMove) {
                  currentCenter = mapEvent.camera.center;
                }
              },
              onTap: (tapPosition, point) {
                //print(point);
                _hideMarkerInfo();
              },
            ),
            children: [
              TileLayer(
                // Display map tiles from any source
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server

                userAgentPackageName: 'com.example.app',
                tileUpdateTransformer: _animatedMoveTileUpdateTransformer,
                tileProvider: CancellableNetworkTileProvider(),
                // And many more recommended properties!
              ),
              MarkerLayer(
                markers: markers,
              ),
              RichAttributionWidget(
                // Include a stylish prebuilt attribution widget that meets all requirments
                attributions: [
                  TextSourceAttribution(
                    'No',
                    //    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                  ),
                  // Also add images...
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: AppBar(
                    title: Text('ZodiMap'),
                    centerTitle: false,
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255)
                        .withOpacity(0.5), // Semi-transparent background
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Center(
                          child: Row(
                            children: [
                              Text('Hi, \$User'),
                              SizedBox(
                                  width:
                                      8.0), // Space between text and profile picture
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isEventVisible)
            Positioned(
              top: 80,
              bottom: 50,
              right: 30,
              child: SlideTransition(
                position: _offsetAnimation!,
                child: Popup(runOnPressed: () { _hideMarkerInfo();}, eventTitle: _eventTitle, eventDescription: _eventDescription, eventAddress: _eventAddress, eventDate: _eventDate, eventTimes: _eventTimes, eventApprover: _eventApprover)
              ),
            ),
          Positioned(
            bottom: 8,
            right: 40,
            child: Row(
              children: [
                MapButton(icon: Icons.zoom_in, onPressed: _zoomIn),
                SizedBox(width: 8),
                MapButton(icon: Icons.zoom_out, onPressed: _zoomOut),
                SizedBox(width: 8),
                MapButton(icon: Icons.refresh, onPressed: _resetOrientation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const MapButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.grey.shade300.withOpacity(0)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(66, 175, 172, 172),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FloatingActionButton(
              onPressed: onPressed,
              child: Icon(icon, size: 20),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inspired by the contribution of [rorystephenson](https://github.com/fleaflet/flutter_map/pull/1475/files#diff-b663bf9f32e20dbe004bd1b58a53408aa4d0c28bcc29940156beb3f34e364556)
final _animatedMoveTileUpdateTransformer = TileUpdateTransformer.fromHandlers(
  handleData: (updateEvent, sink) {
    final id = AnimationId.fromMapEvent(updateEvent.mapEvent);

    if (id == null) return sink.add(updateEvent);
    if (id.customId != _MyHomePageState._useTransformerId) {
      if (id.moveId == AnimatedMoveId.started) {
        debugPrint('TileUpdateTransformer disabled, using default behaviour.');
      }
      return sink.add(updateEvent);
    }

    switch (id.moveId) {
      case AnimatedMoveId.started:
        debugPrint('Loading tiles at animation destination.');
        sink.add(
          updateEvent.loadOnly(
            loadCenterOverride: id.destLocation,
            loadZoomOverride: id.destZoom,
          ),
        );
        break;
      case AnimatedMoveId.inProgress:
        // Do not prune or load during movement.
        break;
      case AnimatedMoveId.finished:
        debugPrint('Pruning tiles after animated movement.');
        sink.add(updateEvent.pruneOnly());
        break;
    }
  },
);
