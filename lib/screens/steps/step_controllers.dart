import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muslim_mariage/screens/profile/upload_photo.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';
import 'package:muslim_mariage/widgets/text_widget.dart';

final TextEditingController userNameController = TextEditingController();
final TextEditingController fatherController = TextEditingController();
final TextEditingController motherController = TextEditingController();
final TextEditingController baradhariController = TextEditingController();
final TextEditingController dobController = TextEditingController();
final TextEditingController heightController = TextEditingController();
final TextEditingController qualificationController = TextEditingController();
final TextEditingController jobOccupationController = TextEditingController();
final TextEditingController yourselfController = TextEditingController();
TextEditingController controller = TextEditingController();

String _profileCreator = 'Self';
String _selectedGender = 'Male';
String _selectedMaritalStatus = 'UnMarried';
String _selectedSect = 'MASLAK E ALA HAZRAT';

void saveProfile(BuildContext context) {
  // Check if name fields have at least 4 characters
  if (fatherController.text.length < 4 || motherController.text.length < 4) {
    showAlert(
        'Father and Mother names must be at least 4 characters long.', context);
    return;
  }

  // Check if Date of Birth is selected and calculate the age
  if (dobController.text.isEmpty) {
    showAlert('Please select your Date of Birth.', context);
    return;
  }

  DateTime dob = DateFormat('dd/MM/yy').parse(dobController.text);
  int age = DateTime.now().year - dob.year;
  if (DateTime.now().month < dob.month ||
      (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
    age--;
  }

  // Age validation based on gender
  if (_selectedGender == 'Female' && age < 18) {
    showAlert('Females must be at least 18 years old.', context);
    return;
  } else if (_selectedGender == 'Male' && age < 21) {
    showAlert('Males must be at least 21 years old.', context);
    return;
  }

  // Check if all fields are filled
  if (fatherController.text.isEmpty ||
      motherController.text.isEmpty ||
      dobController.text.isEmpty ||
      qualificationController.text.isEmpty ||
      jobOccupationController.text.isEmpty ||
      controller.text.isEmpty ||
      yourselfController.text.isEmpty ||
      baradhariController.text.isEmpty ||
      heightController.text.isEmpty) {
    showAlert('Please fill all fields before continuing.', context);
    return;
  }

  // Proceed to save profile to Firestore
  FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .update({
    'profileCreator': _profileCreator,
    'fatherName': fatherController.text,
    'motherName': motherController.text,
    'fullName': userNameController.text,
    'dob': dobController.text,
    'sect': _selectedSect,
    'gender': _selectedGender,
    'maritalStatus': _selectedMaritalStatus,
    'qualification': qualificationController.text,
    'jobOccupation': jobOccupationController.text,
    'aboutYourself': yourselfController.text,
    'cast': baradhariController.text,
    "height": heightController.text,
    "salary": controller.text
  }).then((_) {
    showMessageBar("Profile Created Successfully", context);
    Navigator.push(
        context, MaterialPageRoute(builder: (builder) => const UploadPhoto()));
  }).catchError((error) {
    showAlert('Failed to save profile: $error', context);
  });
}

showErrorMessage(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(
      message,
      style: TextStyle(color: red),
    )),
  );
}
