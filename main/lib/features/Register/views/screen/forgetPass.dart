// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late final TextEditingController _email;



  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future passwordReset() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      showDialog(context: context, builder: (context) {
        return const AlertDialog(content: Text("Check your E_mail"),
        );
      },
      
      );
    } on FirebaseAuthException catch(e) {
      print(e);
      showDialog(context: context, builder: (context) {
        return AlertDialog(content: Text(e.message.toString()),
        );
      },
      
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 4, 24, 50),
        leading: IconButton(
          icon: const Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.white),
              SizedBox(width: 4), // Adding space between icon and text
            ],
          ),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 4, 24, 50),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 1),
              const Text(
                'Arabni',
                style: TextStyle(
                  color: Color.fromARGB(255, 238, 50, 53),
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Enhancing Urban Mobility',
                style: TextStyle(
                  color: Color.fromARGB(255, 249, 248, 248),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Reset your password",
                style: TextStyle(
                  color: Color.fromARGB(255, 249, 248, 248),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your E-mail',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0), // Corrected padding values
                ),
                style: const TextStyle(color: Colors.black),
              ),
              MaterialButton(onPressed: passwordReset,
              color: const Color.fromARGB(255, 238, 50, 53),
              child: const Text("Reset Password"),
              ),
              
              
              const SizedBox(height: 25),
              Image.asset(
                'assets/images/LoginPic.jpg',
                width: 200,
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}