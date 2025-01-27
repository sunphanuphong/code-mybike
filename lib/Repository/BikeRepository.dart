import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mybike/model/bike_model.dart';

class BikeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BikeModel>> getBikes() {
    return _firestore.collection('bike').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BikeModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
