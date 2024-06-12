// commonAppBar.dart
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
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
            child: Image.network(
                'https://via.placeholder.com/150'), // Replace with user's profile image
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
