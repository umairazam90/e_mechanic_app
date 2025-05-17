import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // REMOVE THIS IMPORT
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart'; // KEEP IF YOU USE IT
import 'local_storage.dart'; // Import your local storage functions

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _errorMessage;

  // ... (rest of your _selectDate and _selectTime methods) ...

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        final appointmentDetails = {
          'userId': userId,
          'vehicleMake': _vehicleMakeController.text,
          'vehicleModel': _vehicleModelController.text,
          'vehicleYear': _vehicleYearController.text,
          'serviceType': _serviceTypeController.text,
          'preferredDate': _selectedDate!.toIso8601String(), // Store as ISO 8601 string
          'preferredTime': _selectedTime!.format(context),
          'location': _locationController.text, // Store location as text for now
          'status': 'Pending',
          'createdAt': DateTime.now().toIso8601String(), // Store creation timestamp
        };

        await saveAppointmentLocal(appointmentDetails);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'You must be logged in to book an appointment.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Please fill all required fields and select date and time.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ... (your form fields) ...
              ElevatedButton(
                onPressed: _bookAppointment, // Use the local _bookAppointment function
                child: const Text('Book Appointment'),
              ),
              // ... (error message display) ...
            ],
          ),
        ),
      ),
    );
  }
}