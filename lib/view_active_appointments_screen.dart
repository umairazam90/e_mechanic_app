import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ViewActiveAppointmentsScreen extends StatefulWidget {
  const ViewActiveAppointmentsScreen({super.key});

  @override
  _ViewActiveAppointmentsScreenState createState() =>
      _ViewActiveAppointmentsScreenState();
}

class _ViewActiveAppointmentsScreenState
    extends State<ViewActiveAppointmentsScreen> {
  List<Map<String, dynamic>> _activeAppointments = [];
  Map<String, dynamic> _selectedAppointment = {};
  String _selectedStatus = 'accept';
  bool _isLoading = true;
  static const List<String> _statuses = [
    'accept',
    'working',
    'finished successfully'
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<File> _getLocalFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/$filename');
    } catch (e) {
      print("Error in _getLocalFile: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> _loadAppointmentsLocal() async {
    try {
      final file = await _getLocalFile('appointments.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          try {
            //  Use json.decode directly and cast the result.
            final dynamic decoded = json.decode(contents);
            if (decoded is List) {
              return decoded.cast<Map<String, dynamic>>();
            } else {
              print('Error: Expected a list, but got ${decoded.runtimeType}');
              return [];
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      print("Error in _loadAppointmentsLocal: $e");
      return [];
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _activeAppointments = await _loadAppointmentsLocal();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load appointments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _activeAppointments = [];
    } finally {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _updateAppointmentStatus() async {
    if (_selectedAppointment.isEmpty) return;

    try {
      List<Map<String, dynamic>> existingAppointments =
      await _loadAppointmentsLocal();

      for (var appointment in existingAppointments) {
        if (_areAppointmentsEqual(appointment, _selectedAppointment)) {
          appointment['status'] = _selectedStatus;
          break;
        }
      }

      final file = await _getLocalFile('appointments.json');
      await file.writeAsString(jsonEncode(existingAppointments));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment status updated!')),
      );
      setState(() {
        _selectedAppointment = {};
        _loadAppointments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _areAppointmentsEqual(
      Map<String, dynamic> appt1, Map<String, dynamic> appt2) {
    if (appt1.keys.length != appt2.keys.length) {
      return false;
    }
    for (final key in appt1.keys) {
      if (appt1[key] != appt2[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Appointments'),
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
                : _activeAppointments.isNotEmpty
                ? Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _activeAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _activeAppointments[index];
                      return _buildAppointmentTile(appointment);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedAppointment.isNotEmpty)
                  _buildStatusUpdateSection(),
              ],
            )
                : const Center(
              child: Text(
                'No active appointments.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(Map<String, dynamic> appointment) {
    final isSelected = _selectedAppointment.isNotEmpty &&
        _areAppointmentsEqual(_selectedAppointment, appointment);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAppointment = appointment;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightBlue[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Car: ${appointment['vehicleMake'] ?? 'N/A'}', // Use vehicleMake
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.blueAccent,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${appointment['location'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black87 : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Issue: ${appointment['serviceType'] ?? 'N/A'}', // Use serviceType
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black87 : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${appointment['preferredDate'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black87 : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${appointment['status'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.green
                    : (appointment['status'] == 'Pending'
                    ? Colors.orange
                    : Colors.green),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Appointment Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedStatus = newValue;
                });
              }
            },
            items: _statuses.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Status',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.blueAccent),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _updateAppointmentStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Update Status', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

