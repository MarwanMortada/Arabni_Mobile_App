import 'package:flutter/material.dart';

class RouteStops extends StatelessWidget {
  final String route;
  final List<String> stops;

  const RouteStops({
    required this.route,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stops for Route: $route'),
      ),
      body: ListView.builder(
        itemCount: stops.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(stops[index]),
          );
        },
      ),
    );
  }
}
