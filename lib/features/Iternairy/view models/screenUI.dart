import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocationScreen(),
    );
  }
}
class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}
class _LocationScreenState extends State<LocationScreen> {
  TextEditingController _locationController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  String location = '';
  String destination = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LocationScreen'),
      ),
      body: Stack(
        children: [
          MapScreen(),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFC486E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _locationController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter Location',
                      labelStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => location = value,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _destinationController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter Destination',
                      labelStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => destination = value,
                    onSubmitted: (_) {
                      _showLocationDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showLocationDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLocationBox(location),
              SizedBox(height: 10),
              _buildLocationBox(destination),
            ],
          ),
        );
      },
    );
  }
  Widget _buildLocationBox(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFFC486E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
  @override
  void dispose() {
    _locationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/tokaeladly/clvuwxqoh022201qpfzn892b4/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidG9rYWVsYWRseSIsImEiOiJjbHZ0em83czgwaWI1Mmltamd5OTg0YjRqIn0.1uYtYa-_SxHmyR8KthDLbA',
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoidG9rYWVsYWRseSIsImEiOiJjbHZ0em83czgwaWI1Mmltamd5OTg0YjRqIn0.1uYtYa-_SxHmyR8KthDLbA',
              'id': 'mapbox.mapbox-streets-vB'
            }),
      ],
    );
  }
}