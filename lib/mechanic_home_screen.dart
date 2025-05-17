import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // To navigate back to login
import 'dart:ui';
import 'view_active_appointments_screen.dart';

// Define the StatelessWidget for the Mechanic Home Screen
class MechanicHomeScreen extends StatelessWidget {
  const MechanicHomeScreen({super.key});

  // Function to handle user logout
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Handle any potential logout errors
      print("Error during logout: $e");
      // Optionally show a snackbar or error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user (can be null)
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // App Bar with title and logout button
      appBar: AppBar(
        title: const Text(
          'Mechanic Home',
          style: TextStyle(color: Colors.white), // Consistent text color
        ),
        backgroundColor: Colors.transparent, // Make appbar transparent
        elevation: 0, // Remove shadow
        actions: <Widget>[
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // White logout icon
            tooltip: 'Logout', // For accessibility
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // Main content of the screen
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/login_background.jpg', // Use the same background image
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(
                    0.2), // Consistent opacity
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Welcome message displaying the user's email (if available)
                  Text(
                    'Welcome, ${user?.email ?? 'Mechanic'}!',
                    style: const TextStyle(
                        fontSize: 24.0, // Increased font size for emphasis
                        fontWeight: FontWeight.bold,
                        color: Colors.white), // White text
                  ),
                  const SizedBox(height: 20.0),
                  // Informative text about the screen
                  const Text(
                    'Manage your active appointments here.',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white70), // Use white70 for less prominent text
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32.0),
                  // Button to navigate to the "View Active Appointments" screen
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the ViewActiveAppointmentsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ViewActiveAppointmentsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // Use the same button style as other screens
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 15.0),
                      textStyle: const TextStyle(fontSize: 18.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('View Active Appointments',
                        style: TextStyle(color: Colors.white)), // White text
                  ),
                  // You can add more buttons or information here for other mechanic functionalities
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

