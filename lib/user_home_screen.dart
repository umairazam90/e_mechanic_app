import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  User? _user;
  List<Map<String, String>> _previousAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndAppointments();
  }

  Future<void> _loadUserDataAndAppointments() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      await _loadPreviousAppointments(_user!.uid);
    }
    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadPreviousAppointments(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'userAppointments_$userId';
    List<String>? savedAppointments = prefs.getStringList(key);
    if (savedAppointments != null) {
      _previousAppointments = savedAppointments.map((apptString) {
        List<String> parts = apptString.split(' | ');
        Map<String, String> apptMap = {};
        for (String part in parts) {
          List<String> keyValue = part.split(': ');
          if (keyValue.length == 2) {
            apptMap[keyValue[0].trim()] = keyValue[1].trim();
          }
        }
        return apptMap;
      }).toList();
    } else {
      _previousAppointments = [];
    }
  }

  Future<void> _saveAppointment(
      String userId, Map<String, String> appointmentDetails) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'userAppointments_$userId';
    _previousAppointments.add(appointmentDetails);
    List<String> apptStrings = _previousAppointments.map((appt) {
      return appt.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(' | ');
    }).toList();
    await prefs.setStringList(key, apptStrings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment detail saved locally!')),
    );
    setState(() {});
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
          AppBar(
            title: const Text(
              'User Home',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome, ${_user?.email ?? 'User'}!',
                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'This is the user home screen.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointmentScreen(
                            onSave: (details) {
                              _saveAppointment(_user!.uid, details);
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Book Appointment',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _showPreviousAppointments(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('View Previous Appointments',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviousAppointments(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Previous Appointments',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.8),
          content: _previousAppointments.isEmpty
              ? const Text('No previous appointments saved.',
              style: TextStyle(color: Colors.white70))
              : SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _previousAppointments.map((appt) {
                return Container(
                  width: MediaQuery.of(context).size.width / 2 - 16,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Car: ${appt['carName'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Reg: ${appt['regNumber'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Location: ${appt['location'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Contact no: ${appt['Contact no'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Issue: ${appt['issue'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Other: ${appt['otherDetails'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
              const Text('Close', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}

// Create a new file named book_appointment_screen.dart:
class BookAppointmentScreen extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  const BookAppointmentScreen({super.key, required this.onSave});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _issueController = TextEditingController();
  final _contactController = TextEditingController();
  final _otherDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/login_background.jpg', // Using same background for consistency
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
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Enter Appointment Details:',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _carNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Car Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter car name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _regNumberController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Registration Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter registration number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _contactController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contact no',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _issueController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Issue',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter issue';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _otherDetailsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Other Details',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Map<String, String> appointmentDetails = {
                          'carName': _carNameController.text,
                          'regNumber': _regNumberController.text,
                          'location': _locationController.text,
                          'issue': _issueController.text,
                          'Contact no': _contactController.text,
                          'otherDetails': _otherDetailsController.text,
                        };
                        // Pass the user ID here!
                        widget.onSave(appointmentDetails);
                        Navigator.pop(context); // Go back to UserHomeScreen
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Save Appointment',
                        style: TextStyle(color: Colors.black)),
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
    _carNameController.dispose();
    _regNumberController.dispose();
    _locationController.dispose();
    _issueController.dispose();
    _contactController.dispose();
    _otherDetailsController.dispose();
    super.dispose();
  }
}

