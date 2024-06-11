import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'screenUI.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final start = TextEditingController();
  final end = TextEditingController();
  bool isVisible = false;
  List<LatLng> routpoints = [const LatLng(52.05884, -1.345583)];

  Future<void> _setCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // When we reach here, permissions are granted and we can access the position.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (position.latitude != 0.0 && position.longitude != 0.0) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            start.text = "${place.name}, ${place.locality}, ${place.country}";
          });
        }
      } catch (e) {
        print('Error retrieving placemarks: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get placemark')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location')),
      );
    }
  }

  Future<void> _getRoute() async {
    try {
      List<Location> startLocation = await locationFromAddress(start.text);
      List<Location> endLocation = await locationFromAddress(end.text);

      if (startLocation.isNotEmpty && endLocation.isNotEmpty) {
        var startLat = startLocation[0].latitude;
        var startLng = startLocation[0].longitude;
        var endLat = endLocation[0].latitude;
        var endLng = endLocation[0].longitude;

        print('Start coordinates: $startLat, $startLng');
        print('End coordinates: $endLat, $endLng');

        var url = Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car'
            '?api_key=5b3ce3597851110001cf624824ee2084bbf44bb2b4e345cf2d72f072'
            '&start=$startLng,$startLat'
            '&end=$endLng,$endLat');

        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          var coordinates = data['features'][0]['geometry']['coordinates'];
          setState(() {
            routpoints = coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
            isVisible = true;
          });
        } else {
          print('Failed to load route: ${response.reasonPhrase}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to load route: ${response.reasonPhrase}')),
          );
        }
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map Screen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 19, 19),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: myInput(
                          controler: start, hint: 'Enter Starting point'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _setCurrentLocation,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                myInput(controler: end, hint: 'Enter Ending point'),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[500],
                  ),
                  onPressed: _getRoute,
                  child: const Text('Press'),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 500,
                  width: 400,
                  child: Visibility(
                    visible: isVisible,
                    child: FlutterMap(
                      options: MapOptions(
                        center: routpoints[0],
                        zoom: 10,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        PolylineLayer(
                          polylineCulling: false,
                          polylines: [
                            Polyline(
                                points: routpoints,
                                color: Colors.blue,
                                strokeWidth: 9)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
