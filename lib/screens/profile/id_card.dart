import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/widgets/save_button.dart';

class IDCard extends StatefulWidget {
  const IDCard({super.key});

  @override
  State<IDCard> createState() => _IDCardState();
}

class _IDCardState extends State<IDCard> {
  File? _idCardPhoto;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _idCardPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePhotos() async {
    // If no photo is selected, show an error alert
    if (_idCardPhoto == null) {
      _showAlert('Please upload your ID card before continuing.');
      return;
    }

    String idCardPhotoUrl;

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload the selected photo to Firebase Storage
      idCardPhotoUrl = await _uploadPhoto(_idCardPhoto!, 'idCard');
      Navigator.pop(context); // Close the loading indicator
    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      _showAlert('Failed to upload ID card. Please try again.');
      return;
    }

    // Save the photo URL to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'idCard': idCardPhotoUrl,
      });

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => const MainDashboard()),
      );
    } catch (e) {
      _showAlert('Failed to save ID card. Please try again.');
    }
  }

  Future<String> _uploadPhoto(File file, String photoType) async {
    String fileName = '$photoType-${DateTime.now().millisecondsSinceEpoch}';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Upload ID Card',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please upload a photo of your ID card.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  const Text('ID Card'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickImage(),
                    child: _buildPhotoTile(
                        image: _idCardPhoto != null
                            ? FileImage(_idCardPhoto!)
                            : null),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SaveButton(
                title: "Continue",
                onTap: _savePhotos,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile({ImageProvider? image}) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 2),
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      child: image == null
          ? const Center(
              child: Icon(
                Icons.add,
                color: Colors.green,
                size: 50,
              ),
            )
          : null,
    );
  }
}
