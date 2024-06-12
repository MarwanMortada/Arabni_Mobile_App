import 'package:flutter/material.dart';
import 'package:maasapp/features/Lines/viewmodels/lines.dart';

class OptionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options Bar'),
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
                    builder: (context) => BusOptions(),
                  ),
                );
              },
              child: Text('Bus'),
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

class BusOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Options'),
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
                    builder: (context) =>
                        LinesScreen(), // Navigate to LinesScreen
                  ),
                );
              },
              child: Text('Mwaslat Misr'),
            ),
            ElevatedButton(
              onPressed: () {
                // Do nothing when Public Transportation button is pressed
              },
              child: Text('Public Transportation'),
            ),
          ],
        ),
      ),
    );
  }
}
