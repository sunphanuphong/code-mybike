import 'dart:async'; // นำเข้า Dart's async library
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qrscan.dart'; // นำเข้าไฟล์ QRScanPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/mainbikeone': (context) => const ControlScreen1(),
        '/qrscan': (context) => const QRScanPage(),
      },
      initialRoute: '/qrscan',
    );
  }
}

class ControlScreen1 extends StatefulWidget {
  const ControlScreen1({super.key});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen1> {
  bool isUnlocked = false;
  bool isAlertEnabled = false;
  bool isAdminControlEnabled = false;
  bool isAdmin = false;
  Timer? _unlockTimer;
  Duration _elapsedDuration = Duration.zero;
  DateTime? _unlockStartTime;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        isAdmin = userDoc['role'] == 'admin';
      });
    }
  }

  void _startUnlockTimer() {
    _unlockStartTime ??= DateTime.now();
    _unlockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedDuration = DateTime.now().difference(_unlockStartTime!);
      });
    });
  }

  void _stopUnlockTimer() {
    _unlockTimer?.cancel();
    setState(() {
      _elapsedDuration = Duration.zero;
      _unlockStartTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Control'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/bike.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),
              const SizedBox(height: 20),

              // สวิตช์ที่ไม่แสดงเฉพาะสำหรับผู้ใช้ที่เป็นแอดมิน
              if (isAdmin) ...[
                _buildSwitchRow('เปิดแจ้งเตือนการเตือน', isAlertEnabled, (value) {
                  setState(() {
                    isAlertEnabled = value;
                  });
                }),
                _buildSwitchRow('ควบคุมรถยนต์โดย Admin', isAdminControlEnabled, (value) {
                  setState(() {
                    isAdminControlEnabled = value;
                  });
                }),
              ],

              // สวิตช์ที่แสดงสำหรับผู้ใช้ทั้งหมด
              _buildSwitchRow('ปลดล็อกรถจักรยาน', isUnlocked, (value) {
                setState(() {
                  isUnlocked = value;
                  if (value) {
                    _startUnlockTimer(); // เริ่มนับเวลาหลังจากเปิด
                  } else {
                    _stopUnlockTimer(); // หยุดการนับเวลาเมื่อปิด
                  }
                });
              }),

              const SizedBox(height: 40),
              const Text(
                'ระยะเวลาการปลดล็อก',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeCircle(_elapsedDuration.inMinutes.toString().padLeft(2, '0')),
                  _buildTimeCircle(':'),
                  _buildTimeCircle((_elapsedDuration.inSeconds % 60).toString().padLeft(2, '0')),
                ],
              ),
              if (isAdmin) ...[
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    print('Admin button pressed');
                  },
                  child: const Text('Admin Function'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCircle(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade50,
        border: Border.all(width: 2, color: Colors.blue),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
