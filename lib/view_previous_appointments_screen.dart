import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<Map<String, dynamic>>> loadAppointmentsLocal(String userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String key = 'appointments_$userId';
  final List<String>? appointmentStrings = prefs.getStringList(key);

  if (appointmentStrings == null || appointmentStrings.isEmpty) {
    return [];
  }
  return appointmentStrings.map((String appointmentString) {
    try {
      return jsonDecode(appointmentString) as Map<String, dynamic>;
    } catch (e) {

      print('Error decoding appointment: $e, string: $appointmentString');
      return <String, dynamic>{}; // Return an empty map for invalid entries.
    }
  }).toList();
}

class ViewPreviousAppointmentsScreen extends StatefulWidget {
  const ViewPreviousAppointmentsScreen({super.key});

  @override
  _ViewPreviousAppointmentsScreenState createState() =>
      _ViewPreviousAppointmentsScreenState();
}

class _ViewPreviousAppointmentsScreenState
    extends State<ViewPreviousAppointmentsScreen> {
  List<Map<String, dynamic>> _previousAppointments = [];
  bool _isLoading = true;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndAppointments();
  }

  Future<void> _loadUserDataAndAppointments() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _loadUserRole(currentUser.uid);
      await _loadPreviousAppointments();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final Map<String, dynamic>? roleData = userDoc.data() as Map<String, dynamic>?;
      final role = roleData != null && roleData.containsKey('role')
          ? roleData['role'] is String ? roleData['role'] : ''
          : '';
      setState(() {
        _userRole = role;
      });
    } catch (e) {
      print("Error loading user role: $e");
      setState(() {
        _userRole = '';
      });
    }
  }

  Future<void> _loadPreviousAppointments() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      List<Map<String, dynamic>> allAppointments =
      await loadAppointmentsLocal(currentUser.uid);

      if (_userRole == 'mechanic') {
        setState(() {
          _previousAppointments = allAppointments
              .where((appointment) =>
          appointment['status'] == 'Completed' ||
              appointment['status'] == 'Cancelled')
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _previousAppointments = allAppointments
              .where((appointment) =>
          appointment['userId'] == currentUser.uid &&
              (appointment['status'] == 'Completed' ||
                  appointment['status'] == 'Cancelled'))
              .toList();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
      appBar: AppBar(
        title: const Text('Previous Appointments'),
      ),
      body: _previousAppointments.isEmpty
          ? const Center(child: Text('No previous appointments.'))
          : ListView.builder(
        itemCount: _previousAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _previousAppointments[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      'Vehicle: ${appointment['vehicleMake']} ${appointment['vehicleModel']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Service: ${appointment['serviceType']}'),
                  Text('Date: ${appointment['preferredDate']}'),
                  Text('Time: ${appointment['preferredTime']}'),
                  Text('Status: ${appointment['status']}'),
                  // ... other details ...
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

