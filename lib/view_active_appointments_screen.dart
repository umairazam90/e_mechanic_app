import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Hard-coded ID that owns the stored appointments
const String kFixedUserId = 'MxHx08iKBBNbgzxqgunZO9G3dj92';

/// Reads all appointments saved under appointments_<userId>
Future<List<Map<String, dynamic>>> loadAppointmentsLocal(
    String kFixeduserId) async {
  final prefs = await SharedPreferences.getInstance();
  final key   = 'appointments_$kFixeduserId';
  final list  = prefs.getStringList(key) ?? [];

  return list.map<Map<String, dynamic>>((s) {
    try { return jsonDecode(s) as Map<String, dynamic>; }
    catch (e) {
      debugPrint('Bad JSON: $e  ➜  $s');
      return <String, dynamic>{};
    }
  }).toList();
}

class ViewPreviousAppointmentsScreen1 extends StatefulWidget {
  const ViewPreviousAppointmentsScreen1({super.key});

  @override
  State<ViewPreviousAppointmentsScreen1> createState() =>
      _ViewPreviousAppointmentsScreenState1();
}

class _ViewPreviousAppointmentsScreenState1
    extends State<ViewPreviousAppointmentsScreen1> {
  List<Map<String, dynamic>> _previousAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousAppointments();
  }

  Future<void> _loadPreviousAppointments() async {
    final allAppointments = await loadAppointmentsLocal(kFixedUserId);

    setState(() {
      _previousAppointments = allAppointments
          .where((a) =>
      (a['status'] == 'Completed' || a['status'] == 'Cancelled'))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Previous Appointments')),
      body: _previousAppointments.isEmpty
          ? const Center(child: Text('No previous appointments.'))
          : ListView.builder(
        itemCount: _previousAppointments.length,
        itemBuilder: (context, index) {
          final a = _previousAppointments[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle: ${a['vehicleMake']} ${a['vehicleModel']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Service: ${a['serviceType']}'),
                  Text('Date: ${a['preferredDate']}'),
                  Text('Time: ${a['preferredTime']}'),
                  Text('Status: ${a['status']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
