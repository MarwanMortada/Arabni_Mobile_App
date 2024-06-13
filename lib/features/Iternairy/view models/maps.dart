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

  TripStep(
      {required this.from,
      required this.to,
      required this.mode,
      required this.output});

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
  // Firebase database reference
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

  void _onDatabaseEvent(DatabaseEvent event) {
    if (event.snapshot != null && event.snapshot is DataSnapshot) {
      DataSnapshot snapshot = event.snapshot as DataSnapshot;
      // Now you can work with the DataSnapshot
      print('Received DataSnapshot: $snapshot');
    } else {
      print('Invalid DataSnapshot received');
    }
  }

  void _fetchTripData() async {
    try {
      final DatabaseEvent event = await _dbRef.once();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value;
        print(
            'Root Data Type: ${data.runtimeType}'); // Debugging line to print root data type
        if (data is Map) {
          setState(() {
            trips = data as Map<dynamic, dynamic>;
          });
        } else if (data is List) {
          setState(() {
            trips = data.asMap(); // Convert list to map
          });
        }
        print('Fetched Trips Data: $trips'); // Debugging line
      } else {
        print('No data received');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<TripStep> _findTrip(String from, String to) {
    print('Searching for trips from: "$from" to: "$to"');

    for (var trip in trips.values) {
      print('Checking trip: $trip');
      var stops = trip['Stops'];
      if (stops is List) {
        print('Trip Stops: $stops'); // Print all stops for debugging

        for (int i = 0; i < stops.length - 1; i++) {
          String stopFrom = stops[i].toString().trim().toLowerCase();
          String stopTo = stops[i + 1].toString().trim().toLowerCase();
          String searchFrom = from.trim().toLowerCase();
          String searchTo = to.trim().toLowerCase();

          print('Checking stops: "$stopFrom" to "$stopTo"');

          if (stopFrom == searchFrom && stopTo == searchTo) {
            var tripStep = TripStep(
              from: from,
              to: to,
              mode: trip['Type'],
              output: {
                'Route': trip['Route'],
                'Line Number': trip['Line_Number']
              },
            );
            print('Match found: $tripStep');
            return [tripStep];
          }
        }
      }
    }
    print('No match found');
    return [];
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

  // Icons for each mode
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

        print('Start coordinates: $startLat, $startLng');
        print('End coordinates: $endLat, $endLng');

        var url = Uri.parse(
            'https://api.openrouteservice.org/v2/directions/$selectedMode'
            '?api_key=5b3ce3597851110001cf624824ee2084bbf44bb2b4e345cf2d72f072'
            '&start=$startLng,$startLat'
            '&end=$endLng,$endLat');

        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          var coordinates = data['features'][0]['geometry']['coordinates'];
          var duration =
              data['features'][0]['properties']['segments'][0]['duration'];
          var dist =
              data['features'][0]['properties']['segments'][0]['distance'];

          setState(() {
            routpoints = coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
            travelTimes[selectedMode] =
                (duration / 60).round(); // convert seconds to minutes and round
            distance =
                (dist / 1000).round(); // convert meters to kilometers and round
            isVisible = true;
            startMarker = LatLng(startLat, startLng);
            endMarker = LatLng(endLat, endLng);

            // Update the trip plan
            tripPlan = [
              TripStep(
                from: start.text,
                to: end.text,
                mode: selectedMode,
                output: {
                  'distance': '${(dist / 1000).toStringAsFixed(2)} km',
                  'time': '${(duration / 60).toStringAsFixed(2)} min',
                },
              ),
            ];
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
          'Itinerary Plan',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 75, 2, 6)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            bool isLargeScreen = screenWidth > 800;
            double iconSize = isLargeScreen ? 40 : 20;
            double padding = isLargeScreen ? 16 : 8;
            double fontSize = isLargeScreen ? 16 : 10;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          color: const Color(0xFFFC486E),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: Container(
                                      height: 30,
                                      child: TextField(
                                        controller: start,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Enter location',
                                          hintStyle: const TextStyle(
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 12.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.my_location),
                                    onPressed: _setCurrentLocation,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: Container(
                                      height: 30,
                                      child: TextField(
                                        controller: end,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Enter destination',
                                          hintStyle: const TextStyle(
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8.0,
                                                  horizontal: 12.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(234, 255, 255, 255),
                          ),
                          onPressed: _searchTrip,
                          child: const Text('Search for trips'),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: modeNames.keys.map((mode) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedMode = mode;
                              });
                              _getRoute();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedMode == mode
                                  ? Colors.blueAccent
                                  : Colors.blueAccent,
                            ),
                            child: Row(
                              children: [
                                Icon(modeIcons[mode],
                                    color: Colors.white, size: iconSize),
                                const SizedBox(width: 5),
                                Text(
                                  modeNames[mode]!,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: fontSize),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: isVisible ? 200 : 300,
                      child: Visibility(
                        visible: isVisible,
                        child: FlutterMap(
                          options: MapOptions(
                            center: routpoints.isNotEmpty
                                ? routpoints[0]
                                : LatLng(0, 0),
                            zoom: 13,
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
                                    strokeWidth: 9),
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
                    ),
                    if (isVisible)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${modeNames[selectedMode]}: ${travelTimes[selectedMode]} min, $distance km',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    Container(
                      color: Colors.white,
                      child: tripPlan.isEmpty
                          ? Center(child: Text('No trip plan found.'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: tripPlan.length,
                              itemBuilder: (context, index) {
                                final step = tripPlan[index];
                                return ListTile(
                                  title: Text('${step.from} to ${step.to}'),
                                  subtitle: Text(
                                      'Mode: ${modeNames[step.mode]}, Distance: ${step.output['distance']}, Time: ${step.output['time']}'),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
