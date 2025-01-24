import 'package:flutter/material.dart';
import 'package:mybike/bike.dart';
import 'package:mybike/bikestatus1.dart' show BikeStatus1Page;
import 'package:mybike/bikestatus2.dart' show BikeStatus2Page;
import 'package:mybike/bikestatus3.dart' show BikeStatus3Page;
import 'package:mybike/login.dart';
import 'package:mybike/mainbikeone.dart'; // นำเข้าหน้าควบคุมจากไฟล์ `mainbikeone.dart`
import 'package:mybike/model/users_model.dart'; // นำเข้า UsersModel
import 'package:mybike/mymap.dart'; // นำเข้า MapsPage
import 'package:mybike/registration.dart';

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String bike = '/bike';
  static const String bikestatus1 = '/bikestatus1';
  static const String bikestatus2 = '/bikestatus2';
  static const String bikestatus3 = '/bikestatus3';
  static const String mainbikeone = '/mainbikeone';
  static const String mymap = '/mymap';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case bike:
        final UsersModel usersModel = settings.arguments as UsersModel;
        return MaterialPageRoute(
            builder: (_) => BikePage(usersModel: usersModel));
      case bikestatus1:
        return MaterialPageRoute(builder: (_) => const BikeStatus1Page());
      case bikestatus2:
        return MaterialPageRoute(builder: (_) => const BikeStatus2Page());
      case bikestatus3:
        return MaterialPageRoute(builder: (_) => const BikeStatus3Page());
      case mainbikeone:
        return MaterialPageRoute(builder: (_) => const ControlScreen1());
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
