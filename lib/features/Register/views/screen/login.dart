import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maasapp/features/Register/views/screen/forgetPass.dart';
import 'package:maasapp/features/Register/views/screen/page.dart';
import 'package:maasapp/features/Register/views/screen/register.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget firebaseUIButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 15, 52, 104),
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      child: Text(text),
    );
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
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 4, 24, 50),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                "Sign in to continue",
                style: TextStyle(
                  color: Color.fromARGB(255, 249, 248, 248),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  icon: Icon(Icons.email),
                  iconColor: Colors.white,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  icon: Icon(Icons.lock),
                  iconColor: Colors.white,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                  onPressed: () async {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email.text,
            password: _password.text,
          );
          print("User signed in successfully");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Screen()),
          );
        } catch (error) {
          print("Error signing in: $error");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text(
                  "Failed to sign in. Please check your credentials."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white , backgroundColor: Colors.transparent, // Black font color
        side: const BorderSide(color: Colors.white), // White border
      ),
      child: const Text("Log In"),
    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/register/', (route) => false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    child: const Text(
                      "Register Now!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0.5),
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
