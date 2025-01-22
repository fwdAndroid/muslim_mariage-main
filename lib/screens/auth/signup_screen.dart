import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/functions.dart';
import 'package:muslim_mariage/screens/auth/login_screen.dart';
import 'package:muslim_mariage/screens/profile/complete_profile.dart';
import 'package:muslim_mariage/services/auth_methods.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _locationControllerA = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool isLoading = false;
  bool passwordConfrimVisible = false;

  //Password Toggle Function
  void toggleShowPassword() {
    setState(() {
      passwordVisible = !passwordVisible; // Toggle the showPassword flag
    });
  }

  void toggleShowPasswordConfrim() {
    setState(() {
      passwordConfrimVisible =
          !passwordConfrimVisible; // Toggle the showPassword flag
    });
  }

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                "assets/logo.png",
                height: 150,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        'Email',
                        style: GoogleFonts.poppins(
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
                      validator: RegisterFunctions().validateEmail,
                      style: GoogleFonts.poppins(color: black),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
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
                          hintStyle:
                              GoogleFonts.poppins(color: black, fontSize: 12)),
                    ),
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
                        'Password',
                        style: GoogleFonts.poppins(
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
                      validator: RegisterFunctions().validatePassword,
                      obscureText: !passwordVisible,
                      controller: _passwordController,
                      style: GoogleFonts.poppins(color: black),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: toggleShowPassword,
                            icon: passwordVisible
                                ? Icon(Icons.visibility_off, color: iconColor)
                                : Icon(Icons.visibility, color: iconColor),
                          ),
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
                          hintText: "Enter Password",
                          hintStyle:
                              GoogleFonts.poppins(color: black, fontSize: 12)),
                    ),
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
                        'Re-enter Password',
                        style: GoogleFonts.poppins(
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
                      validator: _validateConfirmPassword,
                      obscureText: !passwordConfrimVisible,
                      controller: _reenterController,
                      style: GoogleFonts.poppins(color: black),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: toggleShowPasswordConfrim,
                            icon: passwordConfrimVisible
                                ? Icon(Icons.visibility_off, color: iconColor)
                                : Icon(Icons.visibility, color: iconColor),
                          ),
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
                          hintText: "Re-enter Password",
                          hintStyle:
                              GoogleFonts.poppins(color: black, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        'Phone Number',
                        style: GoogleFonts.poppins(
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
                      controller: _phoneNumberController,
                      style: GoogleFonts.poppins(color: black),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone,
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
                          hintText: "Phone Number",
                          hintStyle:
                              GoogleFonts.poppins(color: black, fontSize: 12)),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Location",
                              style: GoogleFonts.poppins(
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                          TextFormField(
                            controller: _locationControllerA,
                            decoration: InputDecoration(
                              hintText: 'Enter State',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Address',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (_emailController.text.isEmpty ||
                            _passwordController.text.isEmpty ||
                            _phoneNumberController.text.isEmpty ||
                            _locationControllerA.text.isEmpty ||
                            _locationController.text.isEmpty) {
                          showMessageBar(
                            "Email & Password & PhoneNumber & Location is Required",
                            context,
                          );
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          if (_formKey.currentState!.validate()) {
                            String address = _locationControllerA.text +
                                _locationController.text;
                            try {
                              await AuthMethods().registerUser(
                                  phone: _phoneNumberController.text,
                                  confirmPassword: _reenterController.text,
                                  context: context,
                                  location: address,
                                  email: _emailController.text,
                                  password: _passwordController.text);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          const CompleteProfile()));
                            } catch (e) {
                              showMessageBar(e.toString(), context);
                            }
                          } else {
                            showMessageBar(
                                "Please fill in all fields", context);
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                          backgroundColor: mainColor,
                          fixedSize: const Size(320, 60)),
                      child: Text(
                        "Register",
                        style: TextStyle(color: colorWhite),
                      ),
                    ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => const LoginScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(TextSpan(
                      text: 'Already have an account? ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: mainColor),
                        )
                      ])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirm Password validation function
  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
