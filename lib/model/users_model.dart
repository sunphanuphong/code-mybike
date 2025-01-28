class UsersModel {
  final String userId;
  final String email;
  final String password;
  final String role;
  final String status;

  UsersModel({
    required this.userId,
    required this.email,
    required this.password,
    required this.role,
    this.status = 'inconfirm', 
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
      'role': role,
      'status': status,
    };
  }

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      userId: json['userId'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      status: json['status'],
    );
  }
}
