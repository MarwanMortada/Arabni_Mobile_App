import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'busStops.dart';

class busLines extends StatefulWidget {
  const busLines({Key? key}) : super(key: key);

  @override
  _busLinesState createState() => _busLinesState();
}

class _busLinesState extends State<busLines> {
  late final DatabaseReference _databaseReference;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref().child('Route');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Lines'),
      ),
      body: StreamBuilder(
        stream: _databaseReference.onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No data available'));
          }

          Map<dynamic, dynamic> data = snapshot.data!.snapshot.value;
          List<String> lines =
              data.values.map<String>((value) => value['Route']).toList();
          return ListView.builder(
            itemCount: lines.length,
            itemBuilder: (BuildContext context, int index) {
              String lineName = lines[index];
              return ListTile(
                title: Text(lineName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => busStops(lineName: lineName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
