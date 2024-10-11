import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
//import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider';
import 'dart:ui'; // Import the dart:ui library for ImageFilter

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final int _counter = 0;
  LatLng _initialPosition = LatLng(34.036, -117.850); // Default to London
  bool _locationFetched = false;
  Location location = Location();
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;
  bool _isPanelVisible = false;
  String _panelTitle = '';
  String _panelDescription = '';
  late Animation<double> _animation;
  late MapController _mapController;
  double currentZoom = 9.2;
  LatLng currentCenter = LatLng(51.5, -0.09);
  late final _animatedMapController = AnimatedMapController(vsync: this);
  bool _useTransformer = true;
  int _lastMovedToMarkerIndex = -1;
  static const _useTransformerId = 'useTransformerId';

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

  void _showMarkerInfo(String title, String description) {
    setState(() {
      _panelTitle = title;
      _panelDescription = description;
      _isPanelVisible = true;
    });
    _controller?.forward();
  }

  void _hideMarkerInfo() {
    _controller?.reverse().then((_) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  void _zoomIn() {
    currentZoom = currentZoom + 1;
    _mapController.move(currentCenter, currentZoom);
  }

  void _zoomOut() {
    currentZoom = currentZoom - 1;
    _mapController.move(currentCenter, currentZoom);
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

  @override
  Widget build(BuildContext context) {
    final markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(34.036, -117.850), // coordinates of
        child: GestureDetector(
          onTap: () {
            print("Marker tapped");
            _mapController.move(LatLng(34.036,-117.850), 15.0);
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
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: currentZoom,
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
          if (_isPanelVisible)
            Positioned(
              top: 80,
              bottom: 50,
              right: 30,
              child: SlideTransition(
                position: _offsetAnimation!,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.3, // 30% of screen width
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.1), // Semi-transparent background
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
                          Text(
                            _panelTitle,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Text(_panelDescription),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              // Add your button action here
                              _hideMarkerInfo();
                            },
                            child: Text('Interact with Marker'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
