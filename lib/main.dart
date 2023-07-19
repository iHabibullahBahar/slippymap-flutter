import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slippymap/const.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapping App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapDownloadScreen(),
    );
  }
}

class MapDownloadScreen extends StatefulWidget {
  @override
  _MapDownloadScreenState createState() => _MapDownloadScreenState();
}

class _MapDownloadScreenState extends State<MapDownloadScreen> {
  TextEditingController latController = TextEditingController();
  TextEditingController lonController = TextEditingController();
  List<String> mapLocations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Download'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    decoration: InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: lonController,
                    decoration: InputDecoration(labelText: 'Longitude'),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              downloadMap();
            },
            child: Text('Download Map'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: mapLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(mapLocations[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteMap(index);
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapViewScreen()),
              );
            },
            child: Text('Go to Map View'),
          ),
        ],
      ),
    );
  }

  Future<void> downloadMap() async {
    final latitude = latController.text;
    final longitude = lonController.text;

    // TODO: Implement map download and storage logic here

    setState(() {
      mapLocations.add('$latitude, $longitude');
    });
  }

  Future<void> deleteMap(int index) async {
    setState(() {
      mapLocations.removeAt(index);
    });
  }
}

class MapViewScreen extends StatefulWidget {
  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Map View'),
        ),
        body: isLoading
            ? CircularProgressIndicator()
            : Center(
                child: Container(
                  child: Column(
                    children: [
                      Flexible(
                        child: FlutterMap(
                          options: MapOptions(
                              center: LatLng(ConstData.lat, ConstData.long),
                              zoom: 13.0),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: LatLng(ConstData.lat, ConstData.long),
                                  builder: (ctx) => Container(
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          final bool granted =
                              await requestLocationPermission();
                          if (granted) {
                            // Permission granted, continue with accessing the location
                            getCurrentLocation();
                            print("permission granted");
                          } else {
                            // Permission denied, handle accordingly (e.g., show an error message)
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Text('Request Location Permission'),
                      ),
                    ],
                  ),
                ),
              ));
  }
}

Future<bool> requestLocationPermission() async {
  final PermissionStatus permissionStatus =
      await Permission.locationWhenInUse.request();
  return permissionStatus.isGranted;
}

Future<void> getCurrentLocation() async {
  final LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    print(
        "Location permission is permanently denied. We cannot request permission.");
  } else if (permission == LocationPermission.denied) {
    final LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission is denied");
    } else if (permission == LocationPermission.deniedForever) {
      print("Location permission is permanently denied.");
    } else {
      print("Location permission is granted");
    }
  } else {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double latitude = position.latitude;
      double longitude = position.longitude;
      ConstData.lat = latitude;
      ConstData.long = longitude;
      print('Latitude: $latitude');
      print('Longitude: $longitude');
    } catch (e) {
      print('Error: ${e.toString()}');
      print("new error");
    }
  }
}
