import 'package:flutter/material.dart';
import 'package:mybike/ControlBike.dart';
import 'package:mybike/Repository/BikeRepository.dart';
import 'package:mybike/model/bike_model.dart';

class BikeListController {
  final BikeRepository _bikeRepository = BikeRepository();

  Stream<List<BikeModel>> getBikes() {
    return _bikeRepository.getBikes();
  }

  void navigateToControlScreen(BuildContext context, BikeModel bike) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControlScreen(bike: bike),
      ),
    );
  }
}
