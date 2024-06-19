import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 52,
          color: Color(0xFFFC486E),
        ),
        children: [
          TextSpan(text: 'Arabn'),
          WidgetSpan(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'i',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 52,
                    color: Color(0xFFFC486E),
                  ),
                ),
                Positioned(
                  top: -18,
                  child: Icon(
                    Icons.location_on,
                    color: Color(0xFFFC486E),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: CustomTitle(),
      ),
      body: Center(child: Text('Your main content')),
    ),
  ));
}
