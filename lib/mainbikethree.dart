import 'package:flutter/material.dart';

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
      home: const ControlScreen(),
    );
  }
}

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool isUnlocked = false;
  bool isAlertEnabled = false;
  bool isAdminControlEnabled = false;

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
              // Display the motorcycle image
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/bike.jpg', // Image path
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),
              const SizedBox(height: 20),
              
              // Switches
              _buildSwitchRow('ปลดล็อกรถจักรยาน', isUnlocked, (value) {
                setState(() {
                  isUnlocked = value;
                });
              }),
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
              
              const SizedBox(height: 40),
              
              // Time duration display
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
                  _buildTimeCircle('0'),
                  _buildTimeCircle('.'),
                  _buildTimeCircle('0'),
                  _buildTimeCircle('0'),
                ],
              ),
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
