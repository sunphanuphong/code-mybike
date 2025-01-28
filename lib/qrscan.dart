import 'package:flutter/material.dart';
import 'package:mybike/model/users_model.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'bike.dart';
import 'mymap.dart';

class QRScanPage extends StatefulWidget {
  final UsersModel usersModel;

  const QRScanPage({super.key, required this.usersModel});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate based on the user's role
            if (widget.usersModel.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BikePage(usersModel: widget.usersModel),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MapsPage(usersModel: widget.usersModel),
                ),
              );
            }
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan QR Code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      String? scannedCode = scanData.code;
      print('Scanned data: $scannedCode');

      if (scannedCode != null) {
        if (scannedCode == 'myapp://mainbikeone') {
          Navigator.pushReplacementNamed(context, '/mainbikeone');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid QR Code'),
            ),
          );
        }
      } else {
        // QR code เป็น null
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read QR Code'),
          ),
        );
      }

      // ปิดกล้อง QR Scanner
      controller.pauseCamera();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
