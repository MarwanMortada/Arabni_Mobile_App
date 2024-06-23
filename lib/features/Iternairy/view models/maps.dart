import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:maasapp/core/widgets/AppBar/appBar.dart';
import 'package:maasapp/core/widgets/sideBar.dart';

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
  final startController = TextEditingController();
  final endController = TextEditingController();
  late DatabaseReference _dbRef;
  Map<dynamic, dynamic> trips = {}; // State variable to store trips data
  List<TripStep> tripPlan = [];
  int _currentStep = 0; // Initialize currentStep

  bool isTripPlanVisible = false;
  bool isGetRouteVisible = false;
  List<LatLng> routpoints = [];
  List<Marker> stopMarkers = []; // Add a list for stop markers
  String selectedMode = 'driving-car';
  MapController mapController = MapController(); // Initialize MapController

  // Default location to be displayed when the screen is loaded
  LatLng defaultLocation =
      const LatLng(30.033333, 31.233334); // Example: Cairo, Egypt

  List<String> startSuggestions = [];
  List<String> endSuggestions = [];

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

List<TripStep> _findTrip(String from, String to, {bool reverseStops = false}) {
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
        if (reverseStops) {
          routeStops = routeStops.reversed.toList();
        }
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
  String location = startController.text.trim();
  String destination = endController.text.trim();

  print('Searching for trip from: "$location" to: "$destination"');

  if (location.isNotEmpty && destination.isNotEmpty) {
    List<TripStep> tripPlan = _findTrip(location, destination);
    if (tripPlan.isEmpty) {
      tripPlan = _findTrip(destination, location, reverseStops: true); // Handle swapped scenario with reversed stops
    }
    setState(() {
      this.tripPlan = tripPlan;
      isTripPlanVisible = tripPlan.isNotEmpty;
      _currentStep = 0; // Reset currentStep when a new trip plan is found
      stopMarkers = []; // Reset stop markers
    });
    if (tripPlan.isNotEmpty) {
      print('Trip found to the destination.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip found to the destination.')),
      );
      _calculateTimesAndDistances(); // Calculate times and distances after finding trips
      _addStopMarkers(); // Add markers for each stop
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


  Future<Map<String, dynamic>> _getDistanceAndDuration(
      LatLng start, LatLng end) async {
    var url =
        Uri.parse('https://api.openrouteservice.org/v2/directions/$selectedMode'
            '?api_key=5b3ce3597851110001cf624824ee2084bbf44bb2b4e345cf2d72f072'
            '&start=${start.longitude},${start.latitude}'
            '&end=${end.longitude},${end.latitude}');

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var segment = data['features'][0]['properties']['segments'][0];
      return {'distance': segment['distance'], 'duration': segment['duration']};
    } else {
      print('Failed to get distance and duration: ${response.statusCode}');
      return {'distance': 0, 'duration': 0};
    }
  }

  Future<void> _calculateTimesAndDistances() async {
    for (var tripStep in tripPlan) {
      var stopsList = tripStep.output['Stops']?.split(' -> ') ?? [];
      for (int i = 0; i < stopsList.length - 1; i++) {
        var startStop = stopsList[i];
        var endStop = stopsList[i + 1];
        var startCoords = await locationFromAddress(startStop);
        var endCoords = await locationFromAddress(endStop);
        if (startCoords.isNotEmpty && endCoords.isNotEmpty) {
          var startLatLng =
              LatLng(startCoords[0].latitude, startCoords[0].longitude);
          var endLatLng = LatLng(endCoords[0].latitude, endCoords[0].longitude);
          var result = await _getDistanceAndDuration(startLatLng, endLatLng);
          tripStep.output['${startStop}to$endStop'] =
              'Distance: ${(result['distance'] / 1000).toStringAsFixed(2)} km, Duration: ${(result['duration'] / 60).toStringAsFixed(2)} min';
        }
      }
    }
    setState(() {});
  }

  Future<void> _getRoute() async {
    try {
      List<Location> startLocation =
          await locationFromAddress(startController.text);
      List<Location> endLocation =
          await locationFromAddress(endController.text);

      if (startLocation.isNotEmpty && endLocation.isNotEmpty) {
        var startLat = startLocation[0].latitude;
        var startLng = startLocation[0].longitude;
        var endLat = endLocation[0].latitude;
        var endLng = endLocation[0].longitude;

        print('Start coordinates: $startLat, $startLng');
        print('End coordinates: $endLat, $endLng');

        // Prepare the waypoints
        List<LatLng> waypoints = [LatLng(startLat, startLng)];
        for (var marker in stopMarkers) {
          waypoints.add(marker.point);
        }
        waypoints.add(LatLng(endLat, endLng));

        // Build the waypoints query
        String waypointsQuery = waypoints
            .map((point) => '${point.longitude},${point.latitude}')
            .join('|');

        var url = Uri.parse(
            'https://api.openrouteservice.org/v2/directions/$selectedMode'
            '?api_key=5b3ce3597851110001cf624824ee2084bbf44bb2b4e345cf2d72f072'
            '&start=$startLng,$startLat'
            '&end=$endLng,$endLat'
            '&waypoints=$waypointsQuery');

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
            travelTimes[selectedMode] = duration.toInt();
            distance = dist.toInt();
            startMarker = LatLng(startLat, startLng);
            endMarker = LatLng(endLat, endLng);
            _itinerarySteps = data['features'][0]['properties']['segments'][0]
                ['steps']; // Store the itinerary steps
            mapController.move(
                startMarker!, 13.0); // Center the map to the start marker
          });
        } else {
          print('Failed to get route: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error occurred while getting route: $e');
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    final url = 'https://api.openrouteservice.org/geocode/autocomplete';
    final response = await http.get(
      Uri.parse(
          '$url?api_key=5b3ce3597851110001cf624824ee2084bbf44bb2b4e345cf2d72f072&text=$query&boundary.country=EG'), // Restricting to Egypt
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<String> suggestions = [];
      for (var result in data['features']) {
        suggestions.add(result['properties']['label']);
      }
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
    } catch (e) {
      print('Error getting LatLng from address: $e');
    }
    return null;
  }

  void _onStartChanged(String query) async {
    if (query.isNotEmpty) {
      final suggestions = await getSuggestions(query);
      setState(() {
        startSuggestions = suggestions;
      });
    } else {
      setState(() {
        startSuggestions = [];
      });
    }
  }

  void _onEndChanged(String query) async {
    if (query.isNotEmpty) {
      final suggestions = await getSuggestions(query);
      setState(() {
        endSuggestions = suggestions;
      });
    } else {
      setState(() {
        endSuggestions = [];
      });
    }
  }

  void _addStopMarkers() async {
    for (var tripStep in tripPlan) {
      var stopsList = tripStep.output['Stops']?.split(' -> ') ?? [];
      for (var stop in stopsList) {
        LatLng? stopLatLng = await getLatLngFromAddress(stop);
        if (stopLatLng != null) {
          setState(() {
            stopMarkers.add(
              Marker(
                width: 80.0,
                height: 80.0,
                point: stopLatLng,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 45,
                ),
              ),
            );
          });
        }
      }
    }
  }

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
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
            startController.text =
                "${place.name}, ${place.locality}, ${place.country}";
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

  Widget _buildDropdownButton() {
    return DropdownButton<String>(
      value: selectedMode,
      onChanged: (String? newValue) {
        setState(() {
          selectedMode = newValue!;
        });
      },
      items: <String>['driving-car', 'cycling-regular', 'foot-walking']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(modeNames[value]!),
        );
      }).toList(),
    );
  }

  Widget _buildGetRouteDetails() {
    return Column(
      children: [
        if (routpoints.isNotEmpty && travelTimes[selectedMode]! > 0)
          Text(
              'Mode: ${modeNames[selectedMode]}, Duration: ${travelTimes[selectedMode]! ~/ 60} minutes, Distance: ${distance! / 1000} km'),
        const SizedBox(height: 10),
        if (_itinerarySteps.isNotEmpty) ...[
          const Text(
            'Itinerary Steps:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          for (var step in _itinerarySteps)
            ListTile(
              title: Text(step['instruction']),
              subtitle: Text(
                  'Distance: ${step['distance']} meters, Duration: ${step['duration']} seconds'),
            ),
        ],
      ],
    );
  }

Widget _buildTripPlanDetails() {
  if (tripPlan.isEmpty) {
  
    return Padding(
      padding: const EdgeInsets.all(8.0),
      //child: Text("No trip plan available."),
    );
  }

  return Visibility(
  visible: isTripPlanVisible,
  child: Column(
    children: tripPlan.asMap().entries.map((entry) {
      int index = entry.key;
      TripStep tripStep = entry.value;
      var stopsList = tripStep.output['Stops']?.split(' -> ') ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index > 0)
            Divider(
              color: Colors.grey,
              thickness: 2,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (stopsList.length > 1)
                    Container(
                      width: 2,
                      height: 40.0 * stopsList.length,
                      color: Colors.pink,
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripStep.mode,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4), // Space between mode and line number
                    Text(
                      'Line Number: ${tripStep.output['Line Number']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8), // Space between line number and stops
                    ...stopsList.asMap().entries.map((stopEntry) {
                      int stopIndex = stopEntry.key;
                      String stop = stopEntry.value;
                      bool isStart = stop.toLowerCase() == tripStep.from.toLowerCase();
                      bool isEnd = stop.toLowerCase() == tripStep.to.toLowerCase();
                      Color stopColor = isStart || isEnd ? Colors.red : Colors.black;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: stopColor,
                                    ),
                                  ),
                                  if (stopIndex != stopsList.length - 1)
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: stopColor,
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stop,
                                  style: TextStyle(
                                      color: stopColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (stopIndex != stopsList.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Text(
                                tripStep.output[
                                        '${stopsList[stopIndex]}to${stopsList[stopIndex + 1]}'] ??
                                    '',
                                style: TextStyle(
                                    color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }).toList(),
  ),
);
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonSideBar(),
      appBar: const CommonAppBar(
        title: 'Arabni',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 400,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController, // Add MapController
                    options: MapOptions(
                      center: defaultLocation, // Default location
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
                      MarkerLayer(
                        markers: [
                          if (startMarker != null)
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: startMarker!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 45,
                              ),
                            ),
                          if (endMarker != null)
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: endMarker!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 45,
                              ),
                            ),
                          ...stopMarkers, // Add stop markers
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              TextField(
                                controller: startController,
                                decoration: InputDecoration(
                                  hintText: 'Start Location',
                                  border: const OutlineInputBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.my_location),
                                    onPressed: _setCurrentLocation,
                                  ),
                                ),
                                onChanged: _onStartChanged,
                              ),
                              if (startSuggestions.isNotEmpty)
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: startSuggestions.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title:
                                                  Text(startSuggestions[index]),
                                              onTap: () async {
                                                startController.text =
                                                    startSuggestions[index];
                                                startSuggestions = [];
                                                setState(() {});
                                                LatLng? latLng =
                                                    await getLatLngFromAddress(
                                                        startSuggestions[
                                                            index]);
                                                if (latLng != null) {
                                                  setState(() {
                                                    startMarker = latLng;
                                                  });
                                                  mapController.move(
                                                      latLng, 13.0);
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            startSuggestions = [];
                                          });
                                        },
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            children: [
                              TextField(
                                controller: endController,
                                decoration: const InputDecoration(
                                  hintText: 'Destination',
                                  border: OutlineInputBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                onChanged: _onEndChanged,
                              ),
                              if (endSuggestions.isNotEmpty)
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: endSuggestions.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title:
                                                  Text(endSuggestions[index]),
                                              onTap: () async {
                                                endController.text =
                                                    endSuggestions[index];
                                                endSuggestions = [];
                                                setState(() {});
                                                LatLng? latLng =
                                                    await getLatLngFromAddress(
                                                        endSuggestions[index]);
                                                if (latLng != null) {
                                                  setState(() {
                                                    endMarker = latLng;
                                                  });
                                                  mapController.move(
                                                      latLng, 13.0);
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            endSuggestions = [];
                                          });
                                        },
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              initiallyExpanded: true, // Ensure the tile is expanded by default
              title: const Text('Get Route',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDropdownButton(),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _getRoute,
                      child: const Text('Get Route'),
                    ),
                  ],
                ),
                _buildGetRouteDetails(),
              ],
            ),
            ExpansionTile(
              initiallyExpanded: true, // Ensure the tile is expanded by default
              title: const Text('Search Trip',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ElevatedButton(
                  onPressed: _searchTrip,
                  child: const Text('Search Trip'),
                ),
                _buildTripPlanDetails(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}