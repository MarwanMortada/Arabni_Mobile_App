import 'package:flutter/material.dart';
import 'package:maasapp/core/widgets/sideBar.dart';
import 'package:maasapp/features/Lines/viewmodels/busRoutes.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Center(
          child: Text(
            'Arabni',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xFFFC486E),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 15,
            child: ClipOval(
              child: Image.network(
                'https://via.placeholder.com/150',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: CommonSideBar(), // Use the common drawer widget
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, There',
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
                  _buildFavoritePlaceCard(
                      'Home 🏡', 'https://via.placeholder.com/150'),
                  _buildFavoritePlaceCard(
                      'Work 💻', 'https://via.placeholder.com/150'),
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

  Widget _buildFavoritePlaceCard(String title, String imageUrl) {
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
            Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
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

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
