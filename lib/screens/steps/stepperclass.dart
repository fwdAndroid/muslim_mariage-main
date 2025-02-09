import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/profile/upload_photo.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:intl/intl.dart';
import 'package:muslim_mariage/widgets/text_widget.dart';

class CompleteProfileStepper extends StatefulWidget {
  @override
  _CompleteProfileStepperState createState() => _CompleteProfileStepperState();
}

class _CompleteProfileStepperState extends State<CompleteProfileStepper> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  String _profileCreator = 'Self';
  String _selectedGender = 'Male';
  String _selectedMaritalStatus = 'UnMarried';
  String _selectedSect = 'MASLAK E ALA HAZRAT';
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _baradhariController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _jobOccupationController =
      TextEditingController();
  final TextEditingController _yourselfController = TextEditingController();
  TextEditingController _controller = TextEditingController();

  List<Step> getSteps() {
    return [
      Step(
        title: Text('Basic Information'),
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildDropdownField(
                  'Profile Creator',
                  ['Self', 'Father', 'Mother', 'Brother', 'Uncle'],
                  _profileCreator, (value) {
                setState(() => _profileCreator = value);
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextField('Full Name', _userNameController),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextField('Father Name', _fatherController),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextField('Mother Name', _motherController),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextField('Cast', _baradhariController),
            ),
            buildDateField('Date of Birth', _dobController),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text('Personal & Professional'),
        content: Column(
          children: [
            _buildDropdownField('Gender', ['Male', 'Female'], _selectedGender,
                (value) {
              setState(() => _selectedGender = value);
            }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildDropdownField(
                  'Marital Status',
                  ['UnMarried', 'Married', 'Divorced', 'Widowed'],
                  _selectedMaritalStatus, (value) {
                setState(() => _selectedMaritalStatus = value);
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextFieldNumber('Height', _heightController, null),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextFieldNumber('Monthly Income', _controller, null),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextField('Qualification', _qualificationController),
            ),
            buildTextField('Job Occupation', _jobOccupationController),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text('Additional Details'),
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildDropdownField(
                  'Your Sect', ['MASLAK E ALA HAZRAT'], _selectedSect, (value) {
                setState(() => _selectedSect = value);
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTextField('About Yourself', _yourselfController,
                  maxLines: 4),
            ),
            SaveButton(title: "Continue", onTap: _saveProfile),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  void _saveProfile() {
    // Check if name fields have at least 4 characters
    if (_fatherController.text.length < 4 ||
        _motherController.text.length < 4) {
      showAlert('Father and Mother names must be at least 4 characters long.',
          context);
      return;
    }

    // Check if Date of Birth is selected and calculate the age
    if (_dobController.text.isEmpty) {
      showAlert('Please select your Date of Birth.', context);
      return;
    }

    DateTime dob = DateFormat('dd/MM/yy').parse(_dobController.text);
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
    if (_fatherController.text.isEmpty ||
        _motherController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _qualificationController.text.isEmpty ||
        _jobOccupationController.text.isEmpty ||
        _controller.text.isEmpty ||
        _yourselfController.text.isEmpty ||
        _baradhariController.text.isEmpty ||
        _heightController.text.isEmpty) {
      showAlert('Please fill all fields before continuing.', context);
      return;
    }

    // Proceed to save profile to Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'profileCreator': _profileCreator,
      'fatherName': _fatherController.text,
      'motherName': _motherController.text,
      'fullName': _userNameController.text,
      'dob': _dobController.text,
      'sect': _selectedSect,
      'gender': _selectedGender,
      'maritalStatus': _selectedMaritalStatus,
      'qualification': _qualificationController.text,
      'jobOccupation': _jobOccupationController.text,
      'aboutYourself': _yourselfController.text,
      'cast': _baradhariController.text,
      "height": _heightController.text,
      "salary": _controller.text
    }).then((_) {
      showMessageBar("Profile Created Successfully", context);
      Navigator.push(context,
          MaterialPageRoute(builder: (builder) => const UploadPhoto()));
    }).catchError((error) {
      showAlert('Failed to save profile: $error', context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text("Complete Profile")),
        body: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < getSteps().length - 1) {
              setState(() => _currentStep++);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          onStepTapped: (int step) {
            setState(() {
              _currentStep = step;
            });
          },
          controlsBuilder: (context, details) {
            if (_currentStep == getSteps().length - 1) {
              // Show only the Save button on the last step
              return SaveButton(
                title: "Save",
                onTap: _saveProfile,
              );
            } else {
              // Show Continue and Cancel buttons for other steps
              return Row(
                children: [
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text('Back'),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: details.onStepContinue,
                    child: Text('Continue'),
                  ),
                ],
              );
            }
          },
          steps: getSteps(),
        ));
  }

  Widget _buildDropdownField(String label, List<String> items,
      String selectedValue, ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration:
          InputDecoration(labelText: label, border: OutlineInputBorder()),
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration:
          InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }

  Widget buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.date_range)),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
        }
      },
    );
  }
}
