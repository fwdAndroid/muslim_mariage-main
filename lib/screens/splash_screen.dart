import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/screens/on_boarding_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedSplashScreen(
      curve: Curves.easeInCirc,
      backgroundColor: mainColor,
      centered: true,
      // Curve curve = ,
      duration: 2000,
      splash: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            height: 100,
            "assets/logo.png",
          ),
          const SizedBox(
            height: 30,
          ),
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
      nextScreen: user != null ? MainDashboard() : OnboardingScreen(),
      splashTransition: SplashTransition.sizeTransition,
      pageTransitionType: PageTransitionType.leftToRight,
    ));
  }
}
