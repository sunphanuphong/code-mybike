import 'package:flutter/material.dart';

class BikeStatus2Page extends StatelessWidget {
  const BikeStatus2Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถานะจักรยานคันที่ 2'),
      ),
      body: const Center(
        child: Text(
          'สถานะจักรยานคันที่ 2',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
