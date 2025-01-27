import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mybike/Controller/BikeController.dart';
import 'package:mybike/model/bike_model.dart';

class ControlScreen extends StatefulWidget {
  final BikeModel bike;

  const ControlScreen({Key? key, required this.bike}) : super(key: key);

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool isUnlocked = false;
  bool isAlertEnabled = false;
  bool isAdminControlEnabled = false;

  late BikeController _bikeController;
  Timer? timer;
  String displayTime = "00:00";
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _bikeController = BikeController(bikeId: widget.bike.bikeId);
    _fetchInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _bikeController.initializeBikeData();
    Map<String, dynamic> status = await _bikeController.fetchBikeStatus();

    setState(() {
      isUnlocked = status['status'];
      isAlertEnabled = status['notification'];
      isAdminControlEnabled = status['adminControl'];

      // Start timer if admin control is enabled
      if (isAdminControlEnabled) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    secondsElapsed = 0;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
        int minutes = secondsElapsed ~/ 60;
        int seconds = secondsElapsed % 60;
        displayTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  void _stopTimer() {
    timer?.cancel();
    setState(() {
      displayTime = "00:00";
      secondsElapsed = 0;
    });
  }

  Future<void> _updateStatus(String field, bool value) async {
    await _bikeController.updateBikeStatus(field, value);

    // Handle timer when admin control is toggled
    if (field == 'adminControl') {
      if (value) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          'ควบคุมจักรยาน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildBikeInfoCard(),
              const SizedBox(height: 20),
              _buildControlSection(),
              const SizedBox(height: 40),
              _buildTimerSection(),
              if (isAdminControlEnabled) _buildAdminControlNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        Text(
          'เวลาในการควบคุม',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeCircle(displayTime.split(':')[0]), // นาที
            Text(
              ':',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            _buildTimeCircle(displayTime.split(':')[1]), // วินาที
          ],
        ),
      ],
    );
  }

  Widget _buildBikeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.motorcycle, color: Colors.blue[600], size: 50),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bike.bikeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              Text(
                'ID: ${widget.bike.bikeId}',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchRow('ปลดล็อกรถจักรยาน', isUnlocked, (value) {
            setState(() {
              isUnlocked = value;
            });
            _updateStatus('status', value);
          }),
          _buildDivider(),
          _buildSwitchRow('เปิดแจ้งเตือนการเตือน', isAlertEnabled, (value) {
            setState(() {
              isAlertEnabled = value;
            });
            _updateStatus('notification', value);
          }),
          _buildDivider(),
          _buildSwitchRow('ควบคุมรถโดย Admin', isAdminControlEnabled, (value) {
            setState(() {
              isAdminControlEnabled = value;
            });
            _updateStatus('adminControl', value);
          }),
        ],
      ),
    );
  }

  Widget _buildAdminControlNotice() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.blue[600]),
            const SizedBox(width: 10),
            Text(
              'Admin Control is Active',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
            activeTrackColor: Colors.blue[200],
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.blue[100],
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildTimeCircle(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(width: 2, color: Colors.blue),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }
}
