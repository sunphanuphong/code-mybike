import 'package:flutter/material.dart';

class BikeStatus3Page extends StatelessWidget {
  const BikeStatus3Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถานะจักรยานคันที่ 3'),
      ),
      body: const Center(
        child: Text(
          'สถานะจักรยานคันที่ 3',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
