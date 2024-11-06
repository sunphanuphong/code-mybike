import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 50,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  _showDialog(context, 'Login Failed', 'Please enter email and password.');
                  return;
                }

                try {
                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null && user.emailVerified) {
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                    if (userDoc.exists) {
                      String role = userDoc['role'] ?? 'user'; 

                      if (role == 'user') {
                        Navigator.pushReplacementNamed(context, '/mymap');
                      } else {
                        Navigator.pushReplacementNamed(context, '/bike');
                      }
                    } else {
                      _showDialog(context, 'Account Not Found', 'Your account could not be found in the system.');
                    }
                  } else {
                    _showDialog(context, 'Email Not Verified', 'Please verify your email before logging in.');
                  }
                } catch (e) {
                  print('Failed to login: $e');
                  _showDialog(context, 'Login Failed', 'Failed to login. Please try again.');
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
