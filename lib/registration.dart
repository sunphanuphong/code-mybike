import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
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
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        _showDialog('Registration Failed', 'Please enter both email and password.');
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (!EmailValidator.validate(email)) {
                        _showDialog('Registration Failed', 'Please enter a valid email address.');
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (password.length < 6) {
                        _showDialog('Registration Failed', 'Password must be at least 6 characters long.');
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          await user.sendEmailVerification();

                          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                            'email': email,
                            'role': 'user',
                          });

                          print('User registered: ${user.uid}');

                          _showDialog(
                            'Registration Success',
                            'User successfully registered! Please check your email to verify your account.',
                            onOk: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          );
                        } else {
                          _showDialog('Registration Failed', 'Registration failed. Please try again.');
                        }
                        
                      } catch (e) {
                        print('Failed to register user: $e');
                        _showDialog('Registration Failed', 'Failed to register user. Please try again later.');
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: const Text('Register'),
                  ),
          ],
        ),
      ),
    );
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
