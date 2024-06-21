import 'package:flutter/material.dart';
import 'package:maasapp/features/Destination/views/home.dart';
import 'package:maasapp/features/Iternairy/view%20models/maps.dart';
import 'package:maasapp/features/Lines/viewmodels/busRoutes.dart';
import 'package:maasapp/features/Profile/views/screen/profile.dart';

class CommonSideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFFC486E),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          ListTile(
            title: Text('Plan a Trip'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Routes & Stops'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BusRoutes(
                          selectedLine: '',
                        )),
              );
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Back'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
            leading: Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}
