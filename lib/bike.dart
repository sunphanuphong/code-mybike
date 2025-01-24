import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mybike/login.dart';

import 'model/users_model.dart';

class BikePage extends StatelessWidget {
  final UsersModel usersModel;

  const BikePage({super.key, required this.usersModel});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('กำลังโหลด...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('เกิดข้อผิดพลาด'),
            ),
            body: const Center(child: Text('ไม่สามารถดึงข้อมูลได้')),
          );
        }
        bool isAdmin = snapshot.data == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: Text(isAdmin ? 'admin' : 'หน้าแรก'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
          ),
          body: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/mainbikeone');
                      },
                      child: buildStatusContainer(
                        context,
                        'assets/bikemyapp.png',
                        'หน้าโปรไฟล์',
                        'คันที่ 1',
                      ),
                    ),
                    // ช่องที่สองเป็นตัวอย่างปุ่มสำหรับหน้าร้านค้า
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/bikestatus2');
                      },
                      child: buildStatusContainer(
                        context,
                        'assets/your_image.png',
                        'หน้าร้านค้า',
                        'เนื้อหาของหน้าร้านค้า',
                      ),
                    ),
                    // ช่องที่สามเป็นตัวอย่างปุ่มสำหรับหน้าตั้งค่า
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/bikestatus3');
                      },
                      child: buildStatusContainer(
                        context,
                        'assets/your_image.png',
                        'หน้าตั้งค่า',
                        'เนื้อหาของหน้าตั้งค่า',
                      ),
                    ),
                    // ช่องที่สี่ แสดงเฉพาะแอดมิน
                    if (isAdmin)
                      InkWell(
                        onTap: () {
                          // เพิ่มการนำทางหรือฟังก์ชั่นที่คุณต้องการให้แอดมินใช้งาน
                          Navigator.pushNamed(context, '/adminPage');
                        },
                        child: buildStatusContainer(
                          context,
                          'assets/admin_image.png',
                          'หน้าแอดมิน',
                          'เนื้อหาสำหรับแอดมิน',
                        ),
                      ),
                  ],
                ),
              ),
              // ปุ่มที่แยกออกมาอยู่ด้านล่าง
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/qrscan');
                      },
                      child: const Text('ไปที่ QR Scan'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/mymap',
                          arguments: usersModel,
                        );
                      },
                      child: const Text('ไปที่แผนที่'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('ผู้ใช้ไม่ล็อกอิน');
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('ไม่พบข้อมูลผู้ใช้');
    }

    // แคสต์เป็น Map<String, dynamic> และเข้าถึงข้อมูล
    final data = userDoc.data() as Map<String, dynamic>;
    return data['role'] ?? 'user';
  }

  Widget buildStatusContainer(
      BuildContext context, String imagePath, String title, String content) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      color: Colors.blue[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 50),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
