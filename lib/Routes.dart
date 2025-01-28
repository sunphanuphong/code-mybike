import 'package:flutter/material.dart';
import 'package:mybike/BikeList.dart';
import 'package:mybike/bike.dart';
import 'package:mybike/login.dart';
import 'package:mybike/model/users_model.dart'; // นำเข้า UsersModel
import 'package:mybike/mymap.dart'; // นำเข้า MapsPage
import 'package:mybike/qrscan.dart';
import 'package:mybike/registration.dart';

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String bike = '/bike';
  static const String mainbikeone = '/mainbikeone';
  static const String mymap = '/mymap';
  static const String bikeList = '/bikeList';
  static const String qrScan = '/qrscan';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case qrScan:
        final UsersModel usersModel = settings.arguments as UsersModel;
        return MaterialPageRoute(
            builder: (_) => QRScanPage(usersModel: usersModel));
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case bike:
        final UsersModel usersModel = settings.arguments as UsersModel;
        return MaterialPageRoute(
            builder: (_) => BikePage(usersModel: usersModel));
      case bikeList:
        return MaterialPageRoute(builder: (_) => BikeListWidget());
      case mymap:
        final UsersModel usersModel = settings.arguments as UsersModel;
        return MaterialPageRoute(
            builder: (_) => MapsPage(usersModel: usersModel));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
