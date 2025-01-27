import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mybike/bike.dart';
import 'package:mybike/login.dart';
import 'package:mybike/model/users_model.dart';

import 'model/bike_model.dart';

class MapsPage extends StatefulWidget {
  final UsersModel usersModel;

  const MapsPage({super.key, required this.usersModel});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Position? userLocation;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  StreamSubscription<DatabaseEvent>? _bikeLocationSubscription;
  final databaseReference = FirebaseDatabase.instance.ref();
  double? bike1Latitude, bike1Longitude;
  List<LatLng> polylineCoordinates = [];
  Polyline? routePolyline;
  Set<Polyline> _polylines = {};
  String bikeName = "จักรยานที่ 1";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String bikeStatus = "ว่าง";
  BitmapDescriptor markerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('gps_data');
  final String googleAPIKey = "AIzaSyBiBXvhX4YenKelpFUA30_R5p_OVkbHy8o";
  BikeModel? currentBike;
  StreamSubscription<DocumentSnapshot>? _bikeDataSubscription;
  @override
  void initState() {
    super.initState();
    _getLocation();
    _listenToBikeLocation();
    _setupBikeDataListener();
  }

  @override
  void dispose() {
    _bikeLocationSubscription?.cancel();
    super.dispose();
  }

  void _navigateBasedOnRole(BuildContext context) {
    if (widget.usersModel.role == 'user') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else if (widget.usersModel.role == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BikePage(
                  usersModel: widget.usersModel,
                )),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showDialog('บริการตำแหน่งถูกระงับ',
          'กรุณาเปิดใช้งานบริการตำแหน่งเพื่อใช้งานต่อ');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showDialog('การอนุญาตตำแหน่งถูกปฏิเสธ',
            'กรุณาอนุญาตการเข้าถึงตำแหน่งเพื่อใช้งาน');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showDialog('การอนุญาตตำแหน่งถูกปฏิเสธ',
          'การอนุญาตการเข้าถึงตำแหน่งถูกปฏิเสธอย่างถาวร ไม่สามารถขออนุญาตได้แล้ว');
      return;
    }

    userLocation = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        userLocation = userLocation;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _listenToBikeLocation() {
    _bikeLocationSubscription = _databaseReference.onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        double? newLatitude = double.tryParse(data['latitude'].toString());
        double? newLongitude = double.tryParse(data['longitude'].toString());

        if (newLatitude != null && newLongitude != null) {
          setState(() {
            bike1Latitude = newLatitude;
            bike1Longitude = newLongitude;
            _updateMarkerForBike();
          });
        }
      }
    });
  }

  void _setupBikeDataListener() {
    _bikeDataSubscription = _firestore
        .collection('bike')
        .doc('bikeName')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          currentBike = BikeModel.fromFirestore(
              snapshot.data() as Map<String, dynamic>, snapshot.id);
          _updateMarkerForBike();
        });
      }
    });
  }

  void _updateMarkerForBike() {
    if (currentBike != null &&
        bike1Latitude != null &&
        bike1Longitude != null) {
      setState(() {
        final isAvailable = currentBike!.status == 'on';
        final markerIcon = isAvailable
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

        _markers = {
          Marker(
            markerId: MarkerId(currentBike!.bikeName),
            position: LatLng(bike1Latitude!, bike1Longitude!),
            infoWindow: InfoWindow(
              title: currentBike!.bikeName,
              snippet: "สถานะ: ${isAvailable ? 'ว่าง' : 'ไม่ว่าง'}",
            ),
            icon: markerIcon,
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Bike'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _navigateBasedOnRole(context);
          },
        ),
      ),
      body: userLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // ปุ่มสแกน QR ในกรอบสีน้ำเงิน
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                        onPressed: () {
                          // นำทางไปยังหน้า QR Scanner
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const QRScanPage(), // ใช้ QRScanPage ของคุณ
                          //   ),
                          // );
                        },
                      ),
                      Text(
                        "สแกน QR Code",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          userLocation!.latitude, userLocation!.longitude),
                      zoom: 15,
                    ),
                    polylines: routePolyline != null
                        ? Set<Polyline>.of([routePolyline!])
                        : {},
                    markers: _markers,
                  ),
                ),
                _buildLocationStatus(
                    bikeName, bikeStatus, bike1Latitude, bike1Longitude),
              ],
            ),
    );
  }

  Widget _buildLocationStatus(
      String title, String status, double? latitude, double? longitude) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bike').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('ไม่พบข้อมูลจักรยาน');
        }

        // Get the first bike document
        var bikeDoc = snapshot.data!.docs.first;
        var bikeData = bikeDoc.data() as Map<String, dynamic>;
        var bike = BikeModel.fromFirestore(bikeData, bikeDoc.id);

        final bool isAvailable = bike.status == 'on';
        final Color statusColor = isAvailable ? Colors.green : Colors.red;
        final String statusText = isAvailable ? "ว่าง" : "ไม่ว่าง";

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_bike,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.bikeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (bike.notification.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "สถานะ: ${bike.notification}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // แสดงปุ่มนำทางเฉพาะเมื่อสถานะเป็น 'on'
              if (isAvailable)
                TextButton.icon(
                  onPressed: () {
                    if (latitude != null && longitude != null) {
                      _addMarker(latitude, longitude);
                    }
                  },
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text('นำทาง'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _addMarker(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Latitude or Longitude')),
      );
      return;
    }

    final marker = Marker(
      markerId: MarkerId('${latitude}_${longitude}'),
      position: LatLng(latitude, longitude),
      infoWindow: const InfoWindow(title: 'Custom Pin'),
    );

    setState(() {
      _markers.add(marker);
      if (mapController != null) {
        mapController
            .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
      }
    });

    await _getDirections(
      LatLng(userLocation!.latitude, userLocation!.longitude),
      LatLng(latitude, longitude),
    );
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleAPIKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["routes"].isNotEmpty) {
        final route = data["routes"][0]["overview_polyline"]["points"];
        polylineCoordinates = _decodePolyline(route);
        setState(() {
          routePolyline = Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: const Color.fromARGB(255, 15, 83, 255),
            width: 5,
          );
          if (routePolyline != null) {
            _polylines
                .add(routePolyline!); // ใช้ ! เพื่อบอกว่าเราแน่ใจว่าไม่ใช่ null
          } else {
            print("routePolyline is null!");
          }
        });
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }
}
