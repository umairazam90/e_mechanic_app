import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic> appointmentData;
  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
    required this.appointmentData,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointmentData['status'];
  }
  Future<void> _updateAppointmentStatus() async {
    if (_selectedStatus != null) {
      try {

        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .update({'status': _selectedStatus});


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final DateTime preferredDate =
    (widget.appointmentData['preferredDate'] as Timestamp).toDate();
    final String preferredTime = widget.appointmentData['preferredTime'];
    final String serviceType = widget.appointmentData['serviceType'];
    final String vehicleMake = widget.appointmentData['vehicleMake'];
    final String vehicleModel = widget.appointmentData['vehicleModel'];
    final String location = widget.appointmentData['location'];
    final String userId = widget.appointmentData['userId'];

    return Scaffold(

      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Appointment ID: ${widget.appointmentId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text('User ID: $userId'),
            Text('Service: $serviceType'),
            Text('Vehicle: $vehicleMake $vehicleModel'),
            Text('Date: ${DateFormat('dd-MM-yyyy').format(preferredDate)}'),
            Text('Time: $preferredTime'),
            Text('Location: $location'),
            const SizedBox(height: 24.0),
            const Text(
              'Update Status:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedStatus,
              items: <String>['Pending', 'Accepted', 'In Progress', 'Completed', 'Cancelled']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
            ),

            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _updateAppointmentStatus,
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}