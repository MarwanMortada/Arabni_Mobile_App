import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maasapp/features/Destination/views/home.dart';
import 'package:maasapp/features/Lines/viewmodels/busRoutes.dart';
import 'package:maasapp/features/Lines/viewmodels/busStops.dart';
import 'package:maasapp/features/Lines/viewmodels/lines.dart';
import 'package:maasapp/features/Lines/views/optionsbar.dart';
import 'package:maasapp/features/Profile/views/screen/manageAccoune.dart';
import 'package:maasapp/features/Profile/views/screen/feedback.dart';
import 'package:maasapp/features/Profile/views/screen/helpCenter.dart';
import 'package:maasapp/features/Profile/views/screen/profileScreen.dart';
import 'package:maasapp/features/Register/views/screen/login.dart';
import 'package:maasapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A R A B N I',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 198, 192, 208),
        ),
        useMaterial3: true,
      ),
      home: LinesScreen(),
      routes: {
        '/home/': (context) => HomeScreen(),
        '/optionsbar/': (context) => OptionsBar(),
        '/busRoutes/': (context) => BusRoutes(
              selectedLine: 'Cairo Lines',
            ),
        '/busStops/': (context) => const RouteStops(
              route: '',
              stops: [],
            ),
        '/linesScreen/': (context) => LinesScreen(),
        '/manageAccount/': (context) => ManageAccountScreen(),
        '/feedback/': (context) => FeedbackScreen(),
        '/helpCenter/': (context) => HelpCenterScreen(),
        '/login/': (context) => Login(),
      },
    );
  }
}
