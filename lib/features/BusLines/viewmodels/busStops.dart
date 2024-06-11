import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maasapp/features/BusLines/viewmodels/routeStops.dart';

class BusStops extends StatelessWidget {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Routes'),
      ),
      body: FutureBuilder<DataSnapshot>(
        future: _ref.once().then((event) => event.snapshot),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final routesData = snapshot.data!.value as List<dynamic>;
          return ListView.builder(
            itemCount: routesData.length,
            itemBuilder: (context, index) {
              final routeData = routesData[index] as Map<dynamic, dynamic>;
              final route = routeData['Route'];
              final stops = routeData['Stops'] as List<dynamic>;
              return ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteStops(
                          route: route,
                          stops: List<String>.from(stops),
                        ),
                      ),
                    );
                  },
                  child: Text(route),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
