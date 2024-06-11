import 'package:flutter/material.dart';

class busStops extends StatelessWidget {
  final String lineName;

  const busStops({Key? key, required this.lineName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch stops for the selected line from the database or any other source
    List<String> stops = [
      'Stop 1',
      'Stop 2',
      'Stop 3'
    ]; // Sample stops for demonstration

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Stops - $lineName'),
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
