import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/screens/setting_pages/change_id.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:muslim_mariage/widgets/text_widget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  TextEditingController _jobOccupationController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Fetch data from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Update the controllers with the fetched data
    setState(() {
      descriptionController.text =
          data['aboutYourself'] ?? 'Not Information Available';
      phoneController.text = (data['contactNumber'] ??
          'Not Information Available'); // Convert int to string
      _userNameController.text = data['fullName'] ??
          'Not Information Available'; // Convert int to string
      imageUrl = data['image'];
      _qualificationController.text =
          data['qualification'] ?? 'Not Information Available';
      locationController.text = data['location'] ?? 'INDIA';
      _heightController.text = data['height'] ?? "Not Information Available";
      _controller.text = data['salary'] ?? "Not Information Available";
      _jobOccupationController.text =
          data['jobOccupation'] ?? "Not Information Available";
    });
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  Future<String> uploadImageToStorage(Uint8List image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => ChangeID()));
              },
              child: Text(
                "Change ID",
                style: TextStyle(color: mainColor),
              ))
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back button action
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => selectImage(),
                  child: _image != null
                      ? CircleAvatar(
                          radius: 59, backgroundImage: MemoryImage(_image!))
                      : imageUrl != null
                          ? CircleAvatar(
                              radius: 59,
                              backgroundImage: NetworkImage(imageUrl!))
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                  "assets/Front view of beautiful man.png"),
                            ),
                ),
              ),
              // Profile Picture

              const SizedBox(height: 12),

              // Name Field
              buildTextField('Full Name', _userNameController, Icons.person),
              const SizedBox(height: 12),

              // Number Field
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  } else if (value.length != 10) {
                    return 'Phone number must be exactly 10 characters long';
                  }
                  return null;
                },
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "NUMBER",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  hintText: "Contact Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              buildTextField('Qualification', _qualificationController, null),
              const SizedBox(height: 12),
              buildTextField(
                  'Job Occupation', _jobOccupationController, Icons.work),
              const SizedBox(height: 12),
              // Name Field
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  hintText: "Location",
                  prefixIcon: const Icon(Icons.location_pin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              buildTextFieldNumber('Height', _heightController, null),
              const SizedBox(height: 12),
              buildTextFieldNumber('Monthly Income', _controller, null),
              const SizedBox(height: 12),

              // Description Field
              TextField(
                controller: descriptionController,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: "DESCRIPTION",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  hintText: "About Yourself",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Save Changes Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: mainColor,
                        ),
                      )
                    : SaveButton(
                        title: "Save Changes",
                        onTap: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          String? downloadUrl;
                          if (_image != null) {
                            downloadUrl = await uploadImageToStorage(_image!);
                          } else {
                            downloadUrl = imageUrl;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser!
                                    .uid) // Use widget.uuid here
                                .update({
                              "fullName": _userNameController.text,
                              "aboutYourself": descriptionController
                                  .text, // Convert string to int
                              "contactNumber":
                                  phoneController.text, // Convert string to int
                              "image": downloadUrl,
                              "location": locationController.text,
                              "salary": _controller.text,
                              "height": _heightController.text,
                              "jobOccupation": _jobOccupationController.text,
                              "qualification": _qualificationController.text
                            });
                            showMessageBar(
                                "Profile Update Successfully", context);
                          } catch (e) {
                            // Handle errors here
                            print("Error updating service: $e");
                            showMessageBar("Error While Updating", context);
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => MainDashboard()));
                          }
                        }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
