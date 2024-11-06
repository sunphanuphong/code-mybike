import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'registration.dart';
import 'bike.dart';
import 'package:mybike/qrscan.dart' as qr;
import 'mymap.dart'; // ตรวจสอบว่าชื่อคลาสในไฟล์นี้คือ `MapsPage`
import 'package:mybike/bikestatus1.dart' show BikeStatus1Page;
import 'package:mybike/bikestatus2.dart' show BikeStatus2Page;
import 'package:mybike/bikestatus3.dart' show BikeStatus3Page;
import 'mainbikeone.dart'; // นำเข้าหน้าควบคุมจากไฟล์ `mainbikeone.dart`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/qrscan': (context) => const qr.QRScanPage(),
        '/bike': (context) => const BikePage(),
        '/mymap': (context) => const MapsPage(), // ตรวจสอบว่าชื่อคลาสในไฟล์ `mymap.dart` คือ `MapsPage`
        '/bikestatus1': (context) => const BikeStatus1Page(),
        '/bikestatus2': (context) => const BikeStatus2Page(),
        '/bikestatus3': (context) => const BikeStatus3Page(),
        '/mainbikeone': (context) => const ControlScreen1(), // เส้นทางไปยังหน้าควบคุม
      },
    );
  }
}
