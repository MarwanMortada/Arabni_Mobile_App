import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          const Text('Please Verify your email'),
          TextButton(
            onPressed: () async{
              final user = (FirebaseAuth.instance.currentUser);
              await user?.sendEmailVerification();
            },
            child: const Text('send email verification')
          )
        ],
    );
  }
}