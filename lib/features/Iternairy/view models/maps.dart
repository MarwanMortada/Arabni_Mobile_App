import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class TripStep {
  final String from;
  final String to;
  final String mode;
  final Map<String, String> output;

  TripStep({
    required this.from,
    required this.to,
    required this.mode,
    required this.output,
  });

  @override
  String toString() {
    return 'From: $from, To: $to, Mode: $mode, Output: $output';
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final start = TextEditingController();
  final end = TextEditingController();
  late DatabaseReference _dbRef;
  Map<dynamic, dynamic> trips = {}; // State variable to store trips data
  List<TripStep> tripPlan = [];

  bool isVisible = false;
  List<LatLng> routpoints = [const LatLng(52.05884, -1.345583)];
  String selectedMode = 'driving-car';

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.reference();
    _fetchTripData();
  }

  void _fetchTripData() async {
    try {
      final DatabaseEvent event = await _dbRef.once();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value;
        if (data is Map) {
          setState(() {
            trips = data;
          });
        } else if (data is List) {
          setState(() {
            trips = data.asMap(); // Convert list to map
          });
        }
        print('Fetched Trips Data: $trips');
      } else {
        print('No data received');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<TripStep> _findTrip(String from, String to) {
    print('Searching for trips from: "$from" to: "$to"');

    from = from.trim().toLowerCase();
    to = to.trim().toLowerCase();
    List<TripStep> foundTrips = [];

    for (var trip in trips.values) {
      print('Checking trip: $trip');
      var stops = trip['Stops'];
      if (stops is List) {
        int fromIndex = stops.indexWhere((stop) => stop.toString().trim().toLowerCase() == from);
        int toIndex = stops.indexWhere((stop) => stop.toString().trim().toLowerCase() == to);

        if (fromIndex != -1 && toIndex != -1 && fromIndex < toIndex) {
          List routeStops = stops.sublist(fromIndex, toIndex + 1);
          var tripStep = TripStep(
            from: from,
            to: to,
            mode: trip['Type'],
            output: {
              'Route': trip['Route'],
              'Line Number': trip['Line_Number'],
              'Stops': routeStops.join(' -> ')
            },
          );
          print('Match found: $tripStep');
          foundTrips.add(tripStep);
        }
      }
    }
    if (foundTrips.isEmpty) {
      print('No match found');
    }
    return foundTrips;
  }

  void _searchTrip() {
    String location = start.text.trim();
    String destination = end.text.trim();

    print('Searching for trip from: "$location" to: "$destination"');

    if (location.isNotEmpty && destination.isNotEmpty) {
      List<TripStep> tripPlan = _findTrip(location, destination);
      setState(() {
        this.tripPlan = tripPlan;
      });
      if (tripPlan.isNotEmpty) {
        print('Trip found to the destination.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip found to the destination.')),
        );
      } else {
        print('No trips found to the destination.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No trips found to the destination.')),
        );
      }
    } else {
      print('Location or destination is empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both location and destination.')),
      );
    }
  }

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    super.dispose();
  }

  Map<String, String> modeNames = {
    'driving-car': 'Car',
    'cycling-regular': 'Bike',
    'foot-walking': 'Walking'
  };
  Map<String, int> travelTimes = {
    'driving-car': 0,
    'cycling-regular': 0,
    'foot-walking': 0
  };
  int? distance;
  LatLng? startMarker;
  LatLng? endMarker;
  List<dynamic> _itinerarySteps = [];

  Map<String, IconData> modeIcons = {
    'driving-car': Icons.directions_car,
    'cycling-regular': Icons.directions_bike,
    'foot-walking': Icons.directions_walk,
  };

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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (position.latitude != 0 && position.longitude != 0) {
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

        setState(() {
          startMarker = LatLng(startLat, startLng);
          endMarker = LatLng(endLat, endLng);
        });

        String url =
            'https://api.openrouteservice.org/v2/directions/$selectedMode?api_key=5b3ce3597851110001cf624824ee2084bbf44bb2b4e345cf2d72f072&start=$startLng,$startLat&end=$endLng,$endLat';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var features = data['features'][0];
          var geometry = features['geometry'];
          var coordinates = geometry['coordinates'];

          List<LatLng> points = [];
          for (var coord in coordinates) {
            double lat = coord[1];
            double lng = coord[0];
            points.add(LatLng(lat, lng));
          }

          setState(() {
            routpoints = points;
          });
        } else {
          print('Failed to get directions: ${response.body}');
        }
      } else {
        print('Failed to get locations from addresses.');
      }
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: start,
              decoration: const InputDecoration(labelText: 'Start'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: end,
              decoration: const InputDecoration(labelText: 'End'),
            ),
          ),
          ElevatedButton(
            onPressed: _searchTrip,
            child: const Text('Search for a trip'),
          ),
          ElevatedButton(
            onPressed: _getRoute,
            child: const Text('Get Route'),
          ),
          if (tripPlan.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: tripPlan.length,
                itemBuilder: (context, index) {
                  TripStep trip = tripPlan[index];
                  return ListTile(
                    title: Text('${trip.from} -> ${trip.to}'),
                    subtitle: Text(
                      'Mode: ${trip.mode}\nRoute: ${trip.output['Route']}\nLine Number: ${trip.output['Line Number']}\nStops: ${trip.output['Stops']}',
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: routpoints.isNotEmpty ? routpoints[0] : LatLng(0, 0),
                zoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    Polyline(points: routpoints, color: Colors.blue, strokeWidth: 9),
                  ],
                ),
                if (startMarker != null && endMarker != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: endMarker!,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.location_on),
                          color: Colors.red,
                          iconSize: 45,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}