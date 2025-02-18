import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/steps/step_controllers.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:muslim_mariage/widgets/text_widget.dart';

class CompleteProfileStepper extends StatefulWidget {
  @override
  _CompleteProfileStepperState createState() => _CompleteProfileStepperState();
}

class _CompleteProfileStepperState extends State<CompleteProfileStepper> {
  int _currentStep = 0;

  String _profileCreator = 'Self';
  String _selectedGender = 'Male';
  String _selectedMaritalStatus = 'UnMarried';
  String _selectedSect = 'MASLAK E ALA HAZRAT';

  List<Step> getSteps() {
    return [
      Step(
        state: _currentStep <= 0 ? StepState.editing : StepState.complete,
        isActive: _currentStep >= 0,
        stepStyle: StepStyle(connectorColor: mainColor),
        title: Text('STEP 1'),
        content: Column(
          children: [
            _buildDropdownField(
                'Profile Creator',
                ['Self', 'Father', 'Mother', 'Brother', 'Uncle'],
                _profileCreator, (value) {
              setState(() => _profileCreator = value);
            }),
            const SizedBox(
              height: 12,
            ),
            buildTextField('Full Name', userNameController),
            const SizedBox(
              height: 12,
            ),
            buildTextField('Father Name', fatherController),
            const SizedBox(
              height: 12,
            ),
            buildTextField('Mother Name', motherController),
            const SizedBox(
              height: 12,
            ),
            buildTextField('Cast', baradhariController),
            const SizedBox(
              height: 12,
            ),
            buildDateField('Date of Birth', dobController),
          ],
        ),
      ),
      Step(
        state: _currentStep <= 1 ? StepState.editing : StepState.complete,
        isActive: _currentStep >= 1,
        stepStyle: StepStyle(connectorColor: mainColor),
        title: Text('STEP 2'),
        content: Column(
          children: [
            _buildDropdownField('Gender', ['Male', 'Female'], _selectedGender,
                (value) {
              setState(() => _selectedGender = value);
            }),
            const SizedBox(
              height: 12,
            ),
            _buildDropdownField(
                'Marital Status',
                ['UnMarried', 'Married', 'Divorced', 'Widowed'],
                _selectedMaritalStatus, (value) {
              setState(() => _selectedMaritalStatus = value);
            }),
            const SizedBox(
              height: 12,
            ),
            buildTextFieldNumber('Height', heightController, null),
            const SizedBox(
              height: 12,
            ),
            buildTextFieldNumber('Monthly Income', controller, null),
            const SizedBox(
              height: 12,
            ),
            buildTextField('Qualification', qualificationController),
            const SizedBox(
              height: 12,
            ),
            buildTextField('Job Occupation', jobOccupationController),
          ],
        ),
      ),
      Step(
        state: StepState.complete,
        isActive: _currentStep >= 2,
        title: Text('STEP 3'),
        content: Column(
          children: [
            _buildDropdownField(
                'Your Sect', ['MASLAK E ALA HAZRAT'], _selectedSect, (value) {
              setState(() => _selectedSect = value);
            }),
            const SizedBox(
              height: 12,
            ),
            buildTextField('About Yourself', yourselfController, maxLines: 4),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: mainColor,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              "Complete Profile",
              style: TextStyle(color: colorWhite),
            )),
        body: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            physics: ScrollPhysics(),
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
              return Row(
                children: [
                  if (_currentStep > 0) // Show Back button on Step 2 and Step 3
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('Back'),
                    ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentStep == getSteps().length - 1) {
                        saveProfile(context); // Save the profile when on Step 3
                      } else {
                        details.onStepContinue?.call();
                      }
                    },
                    child: Text(
                      _currentStep == getSteps().length - 1
                          ? "Save"
                          : "Continue",
                      style: TextStyle(
                        color: _currentStep == getSteps().length - 1
                            ? mainColor
                            : null, // Apply mainColor to Save
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
            steps: getSteps()));
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
