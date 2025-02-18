import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/screens/on_boarding_screen.dart';
import 'package:muslim_mariage/screens/steps/stepperclass.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Widget nextScreen = OnboardingScreen(); // Default to onboarding

  @override
  void initState() {
    super.initState();
    _determineNextScreen();
  }

  void _determineNextScreen() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if profile is incomplete
        if (_isProfileIncomplete(userData)) {
          setState(() {
            nextScreen =
                CompleteProfileStepper(); // Navigate to Stepper if incomplete
          });
        } else {
          setState(() {
            nextScreen =
                const MainDashboard(); // Navigate to Dashboard if complete
          });
        }
      } else {
        setState(() {
          nextScreen =
              CompleteProfileStepper(); // Navigate to Stepper if no data found
        });
      }
    }
  }

  bool _isProfileIncomplete(Map<String, dynamic> userData) {
    // Checking if any required field is missing, null, or an empty string
    return (userData['profileCreator'] == null ||
            userData['profileCreator'].toString().trim().isEmpty) ||
        (userData['fatherName'] == null ||
            userData['fatherName'].toString().trim().isEmpty) ||
        (userData['motherName'] == null ||
            userData['motherName'].toString().trim().isEmpty) ||
        (userData['fullName'] == null ||
            userData['fullName'].toString().trim().isEmpty) ||
        (userData['dob'] == null ||
            userData['dob'].toString().trim().isEmpty) ||
        (userData['sect'] == null ||
            userData['sect'].toString().trim().isEmpty) ||
        (userData['gender'] == null ||
            userData['gender'].toString().trim().isEmpty) ||
        (userData['maritalStatus'] == null ||
            userData['maritalStatus'].toString().trim().isEmpty) ||
        (userData['qualification'] == null ||
            userData['qualification'].toString().trim().isEmpty) ||
        (userData['jobOccupation'] == null ||
            userData['jobOccupation'].toString().trim().isEmpty) ||
        (userData['aboutYourself'] == null ||
            userData['aboutYourself'].toString().trim().isEmpty) ||
        (userData['cast'] == null ||
            userData['cast'].toString().trim().isEmpty) ||
        (userData['height'] == null ||
            userData['height'].toString().trim().isEmpty) ||
        (userData['salary'] == null ||
            userData['salary'].toString().trim().isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
        curve: Curves.easeInCirc,
        backgroundColor: mainColor,
        centered: true,
        duration: 2000,
        splash: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              height: 100,
              "assets/logo.png",
            ),
            const SizedBox(height: 30),
            Text(
              "Jilani Sunni Rishte",
              style: GoogleFonts.aboreto(
                  color: const Color(0xffe1ad21),
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        splashIconSize: 250,
        nextScreen: nextScreen, // Dynamically determined screen
        splashTransition: SplashTransition.sizeTransition,
        pageTransitionType: PageTransitionType.leftToRight,
      ),
    );
  }
}
