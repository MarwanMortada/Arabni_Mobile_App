import 'package:flutter/material.dart';
import 'package:maasapp/features/BusLines/viewmodels/busStops.dart';

class BusLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Lines'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusStops(),
                  ),
                );
              },
              child: Text('Bus Routes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Do nothing when Metro button is pressed
              },
              child: Text('Metro'),
            ),
            ElevatedButton(
              onPressed: () {
                // Do nothing when Train button is pressed
              },
              child: Text('Train'),
            ),
          ],
        ),
      ),
    );
  }
}
