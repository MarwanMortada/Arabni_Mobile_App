import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:maasapp/features/Register/views/screen/forgetPass.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:maasapp/core/utils/string_constants.dart';
//import 'package:maasapp/features/Iternairy/view models/screenUI.dart';
import 'package:maasapp/features/Register/views/screen/login.dart';
import 'package:maasapp/features/Register/views/screen/page.dart';
import 'package:maasapp/features/Register/views/screen/register.dart';
import 'package:maasapp/firebase_options.dart';
import 'features/Iternairy/view models/maps.dart';
//import 'features/Iternairy/view models/openstreetmap.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          _initializeFirebase(), // Call your Firebase initialization function
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'A R A B N I',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 198, 192, 208),
              ),
              useMaterial3: true,
            ),
            home: const MapScreen(),
            routes: {
              '/login/': (context) => const Login(),
              '/register/': (context) => const RegisterScreen(),
              '/page/': (context) => const Screen(),
              //'/forgetPass/': (context) => const ForgetPasswordScreen(),

            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
