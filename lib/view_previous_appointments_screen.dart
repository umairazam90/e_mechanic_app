import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert';

// Define the loadAppointmentsLocal function
Future<List<Map<String, dynamic>>> loadAppointmentsLocal(String userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String key = 'appointments_$userId';
  final List<String>? appointmentStrings = prefs.getStringList(key);

  if (appointmentStrings == null || appointmentStrings.isEmpty) {
    return [];
  }

  // Decode each JSON string back into a Map
  return appointmentStrings.map((String appointmentString) {
    try {
      return jsonDecode(appointmentString) as Map<String, dynamic>;
    } catch (e) {
      // Handle potential JSON decoding errors.  This is crucial!
      print('Error decoding appointment: $e, string: $appointmentString');
      return <String, dynamic>{}; // Return an empty map for invalid entries.
    }
  }).toList();
}

class ViewPreviousAppointmentsScreen extends StatefulWidget {
  const ViewPreviousAppointmentsScreen({super.key});

  @override
  State<ViewPreviousAppointmentsScreen> createState() =>
      _ViewPreviousAppointmentsScreenState();
}

class _ViewPreviousAppointmentsScreenState
    extends State<ViewPreviousAppointmentsScreen> {
  List<Map<String, dynamic>> _previousAppointments = [];
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadPreviousAppointments();
  }

  Future<void> _loadPreviousAppointments() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final allAppointments =
      await loadAppointmentsLocal(currentUser.uid); // Pass the user ID
      setState(() {
        _previousAppointments = allAppointments
            .where((appointment) =>
        appointment['userId'] == currentUser.uid &&
            (appointment['status'] == 'Completed' ||
                appointment['status'] == 'Cancelled'))
            .toList();
        _isLoading =
        false; // Set loading to false after data is loaded.
      });
    } else {
      setState(() {
        _isLoading =
        false; // Set loading to false, even if there's no user.
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
      ); // Show a loading indicator
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

