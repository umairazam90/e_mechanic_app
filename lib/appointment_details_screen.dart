// Import necessary Flutter packages
import 'package:flutter/material.dart';

// Import Firebase related packages
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the intl package for date formatting
import 'package:intl/intl.dart';

// Define the StatefulWidget for the Appointment Details Screen
class AppointmentDetailsScreen extends StatefulWidget {
  // Unique identifier for the appointment
  final String appointmentId;

  // Map containing all the appointment data
  final Map<String, dynamic> appointmentData;

  // Constructor to receive appointment ID and data
  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
    required this.appointmentData,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

// Define the State class for the Appointment Details Screen
class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  // State variable to hold the currently selected appointment status
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initialize the selected status with the current status from the appointment data
    _selectedStatus = widget.appointmentData['status'];
  }

  // Asynchronous function to update the appointment status in Firestore
  Future<void> _updateAppointmentStatus() async {
    // Check if a status has been selected
    if (_selectedStatus != null) {
      try {
        // Update the 'status' field in the Firestore document
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .update({'status': _selectedStatus});

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
      } catch (e) {
        // Show an error message if the update fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } else {
      // Show a message if no status is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract appointment details from the appointmentData map
    final DateTime preferredDate =
    (widget.appointmentData['preferredDate'] as Timestamp).toDate();
    final String preferredTime = widget.appointmentData['preferredTime'];
    final String serviceType = widget.appointmentData['serviceType'];
    final String vehicleMake = widget.appointmentData['vehicleMake'];
    final String vehicleModel = widget.appointmentData['vehicleModel'];
    final String location = widget.appointmentData['location'];
    final String userId = widget.appointmentData['userId'];

    return Scaffold(
      // App Bar with the title of the screen
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),

      // Main content of the screen with padding
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Display the Appointment ID
            Text(
              'Appointment ID: ${widget.appointmentId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),

            // Display the User ID
            Text('User ID: $userId'),

            // Display the Service Type
            Text('Service: $serviceType'),

            // Display the Vehicle Make and Model
            Text('Vehicle: $vehicleMake $vehicleModel'),

            // Display the Preferred Date (formatted)
            Text('Date: ${DateFormat('dd-MM-yyyy').format(preferredDate)}'),

            // Display the Preferred Time
            Text('Time: $preferredTime'),

            // Display the Location
            Text('Location: $location'),

            const SizedBox(height: 24.0),

            // Section for updating the appointment status
            const Text(
              'Update Status:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),

            // Dropdown to select the new appointment status
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

            // Button to trigger the update of the appointment status
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