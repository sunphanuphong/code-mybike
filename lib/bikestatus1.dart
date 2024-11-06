import 'package:flutter/material.dart';

class BikeStatus1Page extends StatelessWidget {
  const BikeStatus1Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถานะจักรยานคันที่ 1'),
      ),
      body: const Center(
        child: Text(
          'สถานะจักรยานคันที่ 1',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
