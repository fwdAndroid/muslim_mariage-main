import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/screens/auth/forgot_password.dart';
import 'package:muslim_mariage/screens/auth/signup_screen.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/screens/profile/complete_profile.dart';
import 'package:muslim_mariage/services/auth_methods.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isGoogle = false;
  bool _isPasswordVisible = false;
  bool isLoading = false;
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    _authCheck(); // Check if user is already logged in
  }

  Future<void> _authCheck() async {
    final prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainDashboard()),
        );
      }
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('remember_me', isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png', // Replace with your icon asset
              height: 200,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  style: TextStyle(
                    color: black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 8, top: 15),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: mainColor,
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor)),
                    fillColor: textColor,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.email,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password",
                  style: TextStyle(
                    color: black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  controller: passController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 8, top: 15),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: mainColor,
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor)),
                    fillColor: textColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                          _saveRememberMe();
                        });
                      },
                    ),
                    Text(
                      'Remember Me',
                      style: GoogleFonts.plusJakartaSans(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const ForgotPassword()));
                  },
                  child: const Text("Forgot Password"),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty || passController.text.isEmpty) {
                showMessageBar(
                  "Email & Password is Required",
                  context,
                );
              } else {
                setState(() {
                  isLoading = true;
                });

                String result = await AuthMethods().loginUpUser(
                  email: emailController.text.trim(),
                  pass: passController.text.trim(),
                );

                if (result == 'success') {
                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  // Get user document from Firestore using UID
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
                  if (userDoc.exists) {
                    _saveRememberMe();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (builder) => MainDashboard()),
                    );
                  } else {
                    showMessageBar("User document not found", context);
                  }
                } else {
                  showMessageBar(result, context);
                }

                setState(() {
                  isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
                backgroundColor: mainColor,
                fixedSize: const Size(320, 60)),
            child: Text(
              "Login",
              style: TextStyle(color: colorWhite),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: iconColor,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'OR LOGIN WITH',
                    style: TextStyle(
                      color: black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: iconColor,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          isGoogle
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: FlutterSocialButton(
                    buttonType: ButtonType.google,
                    onTap: () async {
                      setState(() {
                        isGoogle = true;
                      });

                      try {
                        // Perform Google sign-in
                        await AuthMethods().signInWithGoogle();

                        // Fetch the current user's UID
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        DocumentSnapshot userDoc = await FirebaseFirestore
                            .instance
                            .collection("users")
                            .doc(uid)
                            .get();

                        if (userDoc.exists) {
                          // Retrieve user data
                          Map<String, dynamic>? userData =
                              userDoc.data() as Map<String, dynamic>?;

                          String? fullName = userData?['fullName'];

                          if (fullName == null || fullName.isEmpty) {
                            // Navigate to CompleteProfile if profile is incomplete
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      const CompleteProfile()),
                            );
                          } else {
                            // Navigate to MainDashboard if everything is complete
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => MainDashboard()),
                            );
                          }
                        } else {
                          // Create a new user document for new users
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .set({
                            "email": FirebaseAuth.instance.currentUser!.email,
                            "uid": uid,
                            "fullName": "",
                            "contactNumber": FirebaseAuth
                                    .instance.currentUser!.phoneNumber ??
                                "",
                            "location": "",
                            "status": "pending",
                            "favorite": []
                          });

                          // Navigate to VerificationPage for new users
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => CompleteProfile()),
                          );
                        }
                      } catch (e) {
                        showMessageBar(
                            "Error during sign-in. Please try again. $e",
                            context);
                      } finally {
                        setState(() {
                          isGoogle = false;
                        });
                      }
                    },
                  ),
                ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const SignupScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(TextSpan(
                  text: 'Don’t have an account? ',
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: mainColor),
                    )
                  ])),
            ),
          )
        ],
      ),
    );
  }
}
