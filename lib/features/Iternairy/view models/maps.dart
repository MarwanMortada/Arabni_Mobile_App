import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mapbox Example',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
