import 'package:flutter/material.dart';
import 'package:maasapp/features/Profile/views/screen/profileScreen.dart';

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
            title: Text('Plan a Trip'),
            onTap: () {
              // Add functionality for Plan a Trip button
            },
          ),
          ListTile(
            title: Text('Routes & Stops'),
            onTap: () {
              // Add functionality for Routes & Stops button
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
