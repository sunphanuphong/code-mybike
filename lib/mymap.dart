import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Position? userLocation;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  final databaseReference = FirebaseDatabase.instance.ref();
  double? bike1Latitude, bike1Longitude, bike2Latitude, bike2Longitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _listenToBikeLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showDialog('บริการตำแหน่งถูกระงับ', 'กรุณาเปิดใช้งานบริการตำแหน่งเพื่อใช้งานต่อ');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showDialog('การอนุญาตตำแหน่งถูกปฏิเสธ', 'กรุณาอนุญาตการเข้าถึงตำแหน่งเพื่อใช้งาน');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showDialog('การอนุญาตตำแหน่งถูกปฏิเสธ', 'การอนุญาตการเข้าถึงตำแหน่งถูกปฏิเสธอย่างถาวร ไม่สามารถขออนุญาตได้แล้ว');
      return;
    }

    userLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = userLocation;
    });
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
  databaseReference.child('gps_data').onValue.listen((event) {
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      double? newLatitude = double.tryParse(data['latitude'].toString());
      double? newLongitude = double.tryParse(data['longitude'].toString());

      // Check if there is a significant change in the position
      if (newLatitude != null && newLongitude != null &&
          (bike1Latitude != newLatitude || bike1Longitude != newLongitude)) {

        setState(() {
          bike1Latitude = newLatitude;
          bike1Longitude = newLongitude;
          bike2Latitude = newLatitude + 0.001;
          bike2Longitude = newLongitude + 0.001;

          _markers = {
            Marker(
              markerId: const MarkerId('bike1'),
              position: LatLng(bike1Latitude!, bike1Longitude!),
              infoWindow: const InfoWindow(
                title: "จักรยานที่ 1",
                snippet: "สถานะ: ว่าง",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
            Marker(
              markerId: const MarkerId('bike2'),
              position: LatLng(bike2Latitude!, bike2Longitude!),
              infoWindow: const InfoWindow(
                title: "จักรยานที่ 2",
                snippet: "สถานะ: ไม่ว่าง",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          };
        });
      }
    }
  });
}


  void _launchNavigation(double latitude, double longitude) async {
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'ไม่สามารถเปิด Google Maps ได้';
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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: userLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(userLocation!.latitude, userLocation!.longitude),
                      zoom: 15,
                    ),
                    markers: _markers,
                  ),
                ),
                _buildLocationStatus("จักรยานที่ 1", "ว่าง", bike1Latitude, bike1Longitude),
                _buildLocationStatus("จักรยานที่ 2", "ไม่ว่าง", bike2Latitude, bike2Longitude),
              ],
            ),
    );
  }

  Widget _buildLocationStatus(String title, String status, double? latitude, double? longitude) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_bike, color: status == "ว่าง" ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                status,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              if (latitude != null && longitude != null) {
                _launchNavigation(latitude, longitude);
              }
            },
            child: const Text(
              'นำทาง',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
