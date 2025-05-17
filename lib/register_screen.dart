import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'dart:ui';
import 'user_home_screen.dart';
import 'mechanic_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  String _role = 'user';
  bool _obscurePassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          String userId = userCredential.user!.uid;
          String role = _role;

          await _firestore.collection('users').doc(userId).set({
            'role': role,
          });

          _showSuccessDialog(context);
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = 'Firebase Registration Error: ${e.code} - ${e.message}';
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Registration Error: $e';
        });
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your account has been created successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/login_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        // Improved DropdownButtonFormField
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButtonFormField<String>(
                            value: _role,
                            onChanged: (String? newValue) {
                              setState(() {
                                _role = newValue!;
                              });
                            },
                            items: <String>['user', 'mechanic']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Registering as',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0), // Added vertical padding
                            ),
                            dropdownColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        ElevatedButton(
                          onPressed: () {
                            _register(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                            textStyle: const TextStyle(fontSize: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

