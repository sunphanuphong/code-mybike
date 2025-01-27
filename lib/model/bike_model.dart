class BikeModel {
  final String bikeId;
  final String bikeName;
  final String status;
  final String notification;
  final String adminContorl;

  BikeModel(
      {required this.bikeId,
      required this.bikeName,
      required this.status,
      required this.notification,
      required this.adminContorl});

  factory BikeModel.fromFirestore(Map<String, dynamic> data, String bikeId) {
    return BikeModel(
      bikeId: bikeId,
      bikeName: data['bikeName'] ?? 'field bikeName มีค่าว่าง',
      status: data['status'] ?? 'field status มีค่าว่าง',
      notification: data['notification'] ?? 'Field notification มีค่าว่าง',
      adminContorl: data['adminContorl'] ?? 'Field adminContorl มีค่าว่าง',
    );
  }
}
