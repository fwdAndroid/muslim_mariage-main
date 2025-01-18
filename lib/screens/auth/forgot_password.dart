import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/screens/auth/login_screen.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/widgets/save_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = _emailController.text.trim();

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      // Show confirmation and navigate to the login screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Password reset email sent! Please check your email, including the spam folder, for any response')),
      );

      // Navigate to the login screen after a successful password reset email
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) =>
                  const LoginScreen())); // Replace '/login' with your actual login route
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(child: Container()),
          Image.asset(
            "assets/logo.png",
            height: 104,
            width: 104,
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Text(
                "Reset Password",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 16),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    'Email',
                    style: GoogleFonts.plusJakartaSans(
                        color: black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.plusJakartaSans(color: black),
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: iconColor,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainColor)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainColor)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: mainColor)),
                      hintText: "Enter Email Address",
                      hintStyle: GoogleFonts.plusJakartaSans(
                          color: black, fontSize: 12)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SaveButton(
                title: "Reset Password",
                onTap: () async {
                  _sendPasswordResetEmail();
                }),
          ),
          const SizedBox(
            height: 100,
          ),
          Flexible(child: Container()),
        ],
      ),
    );
  }
}
