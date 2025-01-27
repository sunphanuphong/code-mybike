import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mybike/Controller/TimeService.dart';

class BikeController {
  final FirebaseFirestore _firestore;
  final String bikeId;
  final TimerService _timerService;

  BikeController({
    required this.bikeId,
    FirebaseFirestore? firestore,
    TimerService? timerService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _timerService = timerService ?? TimerService();

  Future<void> initializeBikeData() async {
    DocumentReference bikeRef = _firestore.collection('bike').doc(bikeId);
    DocumentSnapshot bikeSnapshot = await bikeRef.get();

    if (!bikeSnapshot.exists) {
      await bikeRef.set({
        'status': 'off',
        'notification': 'off',
        'adminControl': 'InActive',
        'bikeName': 'null'
      });
    }
  }

  Future<void> updateBikeStatus(String field, bool value) async {
    try {
      String newValue = value ? 'on' : 'off';

      if (field == 'adminControl') {
        newValue = value ? 'Active' : 'InActive';

        if (value) {
          _timerService.startTimer();

          await _firestore.collection('bike').doc(bikeId).update({
            field: newValue,
            'timerStartedAt': FieldValue.serverTimestamp(),
            'isTimerRunning': true
          });
        } else {
          _timerService.stopTimer();

          await _firestore.collection('bike').doc(bikeId).update({
            field: newValue,
            'timerStartedAt': null,
            'isTimerRunning': false,
            'lastTimerDuration': _timerService.secondsElapsed
          });
        }
      } else {
        await _firestore
            .collection('bike')
            .doc(bikeId)
            .update({field: newValue});
      }
    } catch (e) {
      print("Error updating Firestore: $e");
      throw Exception('Failed to update bike status: $e');
    }
  }

  Future<void> updateBikeName(String newName) async {
    try {
      DocumentReference bikeRef = _firestore.collection('bike').doc(bikeId);
      await bikeRef.update({'bikeName': newName});
    } catch (e) {
      print("Error updating bike name: $e");
    }
  }

  Future<Map<String, dynamic>> fetchBikeStatus() async {
    DocumentReference bikeRef = _firestore.collection('bike').doc(bikeId);
    DocumentSnapshot bikeSnapshot = await bikeRef.get();

    if (bikeSnapshot.exists) {
      Map<String, dynamic> data = bikeSnapshot.data() as Map<String, dynamic>;
      return {
        'status': data['status'] == 'on',
        'notification': data['notification'] == 'on',
        'adminControl': data['adminControl'] == 'Active',
        'bikeName': data['bikeName'] ?? 'Unnamed Bike',
      };
    } else {
      return {
        'status': false,
        'notification': false,
        'adminControl': false,
        'bikeName': 'Unnamed Bike',
      };
    }
  }

  Future<void> initializeTimer() async {
    try {
      final doc = await _firestore.collection('bike').doc(bikeId).get();
      final data = doc.data();

      if (data != null &&
          data['adminControl'] == 'Active' &&
          data['isTimerRunning'] == true &&
          data['timerStartedAt'] != null) {
        final startTime = (data['timerStartedAt'] as Timestamp).toDate();
        final now = DateTime.now();
        final elapsedSeconds = now.difference(startTime).inSeconds;

        _timerService.setElapsedSeconds(elapsedSeconds);
        _timerService.startTimer();
      }
    } catch (e) {
      print("Error initializing timer: $e");
    }
  }
}
