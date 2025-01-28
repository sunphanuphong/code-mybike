import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/users_model.dart';

class RegisterController {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final void Function(bool isLoading) updateLoadingState;

  RegisterController({
    required this.context,
    required this.emailController,
    required this.passwordController,
    required this.updateLoadingState,
  });

  Future<void> handleRegistration() async {
    updateLoadingState(true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_validateInputs(email, password)) {
      updateLoadingState(false);
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();

        final usersModel = UsersModel(
          userId: user.uid,
          email: email,
          password: password,
          role: 'user',
          status: 'inconfirm',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(usersModel.toJson());

        _showDialog(
          'Registration Success',
          'User successfully registered! Please check your email to verify your account.',
          onOk: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
      } else {
        _showDialog(
            'Registration Failed', 'Registration failed. Please try again.');
      }
    } catch (e) {
      _showDialog('Registration Failed',
          'Failed to register user. Please try again later.');
    } finally {
      updateLoadingState(false);
    }
  }

  bool _validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _showDialog(
          'Registration Failed', 'Please enter both email and password.');
      return false;
    }
    if (!EmailValidator.validate(email)) {
      _showDialog('Registration Failed', 'Please enter a valid email address.');
      return false;
    }
    if (password.length < 6) {
      _showDialog('Registration Failed',
          'Password must be at least 6 characters long.');
      return false;
    }
    return true;
  }

  void _showDialog(String title, String content, {VoidCallback? onOk}) {
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
                if (onOk != null) onOk();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
