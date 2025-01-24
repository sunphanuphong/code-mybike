import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/users_model.dart';

class LoginController {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final void Function(bool isLoading) updateLoadingState;

  LoginController({
    required this.context,
    required this.emailController,
    required this.passwordController,
    required this.updateLoadingState,
  });

  Future<void> handleLogin() async {
    updateLoadingState(true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Login Failed', 'Please enter email and password.');
      updateLoadingState(false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        print('User UID: ${user.uid}');
        print('Email verified: ${user.emailVerified}');

        if (user.emailVerified) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'status': 'confirm'});

          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            print('User data: ${userDoc.data()}');
            final usersModel = UsersModel.fromJson(userDoc.data()!);
            final role = usersModel.role;

            if (role == 'user') {
              Navigator.pushReplacementNamed(
                context,
                '/mymap',
                arguments: usersModel,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                '/bike',
                arguments: usersModel,
              );
            }
          } else {
            _showDialog('Account Not Found',
                'Your account could not be found in the system.');
          }
        } else {
          _showDialog('Email Not Verified',
              'Please verify your email before logging in.');
        }
      }
    } catch (e) {
      print('Failed to login: $e');
      _showDialog('Login Failed', 'Failed to login. Please try again.');
    } finally {
      updateLoadingState(false);
    }
  }

  void _showDialog(String title, String content) {
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
