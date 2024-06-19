import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maasapp/features/Profile/views/screen/profile.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('users/${user?.uid}');

    return FutureBuilder<DataSnapshot>(
      future: databaseReference.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final userData =
              Map<String, dynamic>.from(snapshot.data!.value as Map);
          final profileImage =
              userData['profileImage'] ?? 'https://via.placeholder.com/150';

          return AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
            title: Center(
              child: Text(
                title,
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 15,
                  child: ClipOval(
                    child: Image.network(profileImage),
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
          );
        } else {
          return AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
            title: Center(
              child: Text(
                title,
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
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 15,
                child: ClipOval(
                  child: Image.network('https://via.placeholder.com/150'),
                ),
              ),
              SizedBox(width: 16),
            ],
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
