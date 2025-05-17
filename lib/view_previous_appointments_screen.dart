import 'package:flutter/material.dart';
import 'local_storage.dart'; // Import your local storage functions
import 'package:firebase_auth/firebase_auth.dart'; // Keep if you need user info

class ViewPreviousAppointmentsScreen extends StatefulWidget {
  const ViewPreviousAppointmentsScreen({super.key});

  @override
  State<ViewPreviousAppointmentsScreen> createState() => _ViewPreviousAppointmentsScreenState();
}

class _ViewPreviousAppointmentsScreenState extends State<ViewPreviousAppointmentsScreen> {
  List<Map<String, dynamic>> _previousAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousAppointments();
  }

  Future<void> _loadPreviousAppointments() async {
    final allAppointments = await loadAppointmentsLocal();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _previousAppointments = allAppointments
            .where((appointment) =>
        appointment['userId'] == currentUser.uid &&
            (appointment['status'] == 'Completed' || appointment['status'] == 'Cancelled'))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Vehicle: ${appointment['vehicleMake']} ${appointment['vehicleModel']}', style: const TextStyle(fontWeight: FontWeight.bold)),
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