import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maasapp/features/Destination/views/home.dart';
import 'package:maasapp/features/Lines/viewmodels/busRoutes.dart';
import 'package:maasapp/features/Lines/viewmodels/busStops.dart';
import 'package:maasapp/features/Lines/viewmodels/lines.dart';
import 'package:maasapp/features/Profile/views/accountSettings.dart';
import 'package:maasapp/features/Profile/views/screen/feedback.dart';
import 'package:maasapp/features/Profile/views/screen/helpCenter.dart';
import 'package:maasapp/features/Profile/views/screen/profile.dart';
import 'package:maasapp/features/Register/views/screen/forgetPass.dart';
import 'package:maasapp/features/Register/views/screen/login.dart';
import 'package:maasapp/features/Register/views/screen/page.dart';
import 'package:maasapp/features/Register/views/screen/register.dart';
import 'package:maasapp/firebase_options.dart';
import 'package:maasapp/features/Iternairy/view models/maps.dart';

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
            home: MapScreen(),
            routes: {
              '/busRoutes/': (context) => const BusRoutes(
                    selectedLine: '',
                  ),
              '/busStops/': (context) => const RouteStops(
                    route: '',
                    stops: [],
                  ),
              '/lines/': (context) => LinesScreen(),
              '/login/': (context) => const Login(),
              '/register/': (context) => const RegisterScreen(),
              '/page/': (context) => const Screen(),
              '/forgetPass/': (context) => const ForgetPasswordScreen(),
              '/profile/': (context) => ProfileScreen(),
              '/map/': (context) => MapScreen(),
              '/accountSettings/': (context) => Accountsettings(
                    user: null,
                  ),
              '/helpCenter/': (context) => HelpCenterScreen(),
              '/feedback/': (context) => FeedbackScreen(),
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
