import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<File> _getLocalFile(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/$filename');
}

Future<void> saveAppointmentLocal(Map<String, dynamic> appointmentDetails) async {
  final file = await _getLocalFile('appointments.json');
  List<dynamic> existingAppointments = [];
  if (await file.exists()) {
    final contents = await file.readAsString();
    if (contents.isNotEmpty) {
      try {
        existingAppointments = jsonDecode(contents);
      } catch (e) {
        print('Error decoding existing appointments: $e');
      }
    }
  }
  existingAppointments.add(appointmentDetails);
  await file.writeAsString(jsonEncode(existingAppointments));
}

Future<List<Map<String, dynamic>>> loadAppointmentsLocal() async {
  final file = await _getLocalFile('appointments.json');
  if (await file.exists()) {
    final contents = await file.readAsString();
    if (contents.isNotEmpty) {
      try {
        return (jsonDecode(contents) as List).cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error decoding appointments: $e');
        return [];
      }
    }
  }
  return [];
}