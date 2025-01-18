import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muslim_mariage/screens/auth/login_screen.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate to main dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (builder) => MainDashboard()),
      );
    } else {
      // User is not signed in, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (builder) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/logo.png"),
          )),
        ],
      ),
    );
  }
}
