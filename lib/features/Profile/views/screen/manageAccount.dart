import 'package:flutter/material.dart';

class ManageAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account'),
      ),
      body: Center(
        child: Text(
          'Manage Account Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
