import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Center(
          child: Text(
            'Arabni',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFFFC486E),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
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
                Navigator.pop(
                    context); // Close the drawer if already on profile
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
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFFC486E),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150', // Replace with user's profile image
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Username',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '+20100000000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'useremail@gmail.com',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.manage_accounts),
            title: Text('Manage Account'),
            onTap: () {
              Navigator.pushNamed(context, '/manageAccount/');
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            onTap: () {
              Navigator.pushNamed(context, '/feedback/');
            },
          ),
          ListTile(
            leading: Icon(Icons.help_center),
            title: Text('Help Center'),
            onTap: () {
              Navigator.pushNamed(context, '/helpCenter/');
            },
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Center(
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
