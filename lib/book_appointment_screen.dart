import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert'; // Import for JSON encoding/decoding

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

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Modified _bookAppointment function to use SharedPreferences
  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        final appointmentDetails = {
          'userId': userId,
          'vehicleMake': _vehicleMakeController.text,
          'vehicleModel': _vehicleModelController.text,
          'vehicleYear': _vehicleYearController.text,
          'serviceType': _serviceTypeController.text,
          'preferredDate': _selectedDate!.toIso8601String(),
          'preferredTime': _selectedTime!.format(context),
          'location': _locationController.text,
          'status': 'Pending',
          'createdAt': DateTime.now().toIso8601String(),
        };

        // Use SharedPreferences to save the appointment
        await _saveAppointmentLocal(userId, appointmentDetails);
      } else {
        setState(() {
          _errorMessage =
          'You must be logged in to book an appointment.';
        });
      }
    } else {
      setState(() {
        _errorMessage =
        'Please fill all required fields and select date and time.';
      });
    }
  }

  // Function to save appointment data locally using SharedPreferences
  Future<void> _saveAppointmentLocal(
      String userId, Map<String, String> appointmentDetails) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'appointments_$userId';
    List<String> existingAppointments =
        prefs.getStringList(key) ?? <String>[];
    String newAppointment = jsonEncode(appointmentDetails);
    print('Saving appointment: $newAppointment with key: $key'); // Debugging line
    existingAppointments.add(newAppointment);
    bool success = await prefs.setStringList(key, existingAppointments);
    if (!success) {
      print('Error saving appointment!'); // Debugging line
      // Show a user-friendly message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save appointment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
      }
      Navigator.pop(context); // Only pop if save was successful.
    }
  }

  @override
  void dispose() {
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _serviceTypeController.dispose();
    _locationController.dispose();
    super.dispose();
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
              // Vehicle Make
              TextFormField(
                controller: _vehicleMakeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Make',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle make';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Vehicle Model
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Vehicle Year
              TextFormField(
                controller: _vehicleYearController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Year',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Service Type
              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Date Picker
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Time Picker
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No time selected'
                          : 'Time: ${_selectedTime!.format(context)}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // Book Appointment Button
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Appointment'),
              ),
              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
