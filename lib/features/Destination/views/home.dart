import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maasapp/core/widgets/sideBar.dart';
import 'package:maasapp/core/widgets/AppBar/appBar.dart'; // Import CommonAppBar
import 'package:maasapp/features/Iternairy/view%20models/maps.dart';
import 'package:maasapp/features/Lines/viewmodels/busRoutes.dart'; // Import BusRoutes

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String firstName = 'There';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('users/${user?.uid}');
    DataSnapshot snapshot = await databaseReference.get();
    if (snapshot.exists) {
      setState(() {
        firstName = (snapshot.value as Map)['firstname'] ?? 'There';
      });
    }
  }

  void _navigateToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Arabni'), // Use the common app bar widget
      drawer: CommonSideBar(), // Use the common drawer widget
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $firstName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Check the best mobility option for your trip',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Find your destination',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Where do you want to go',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
                onTap: _navigateToMapScreen, // Navigate to MapScreen on tap
              ),
              SizedBox(height: 16),
              Text(
                'Favourite places',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFavoritePlaceCard('Home', Icons.home),
                  _buildFavoritePlaceCard('Work', Icons.work),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Mobility Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryButton(context, 'Bus', Icons.directions_bus),
                  _buildCategoryButton(
                      context, 'Metro', Icons.subway), // Updated Metro icon
                  _buildCategoryButton(context, 'Train', Icons.train),
                  _buildCategoryButton(context, 'Light Rail',
                      Icons.tram), // Updated Light Rail icon
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritePlaceCard(String title, IconData icon) {
    return Card(
      color: Color(0xFFFC486E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white), // Use Icon widget
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusRoutes(
                selectedLine: title), // Pass the title as the selected line
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFFC486E),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
