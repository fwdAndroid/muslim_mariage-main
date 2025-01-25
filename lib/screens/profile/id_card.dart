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
  File? _bridePhoto;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isBridePhoto) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isBridePhoto) {
          _bridePhoto = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _savePhotos() async {
    String bridePhotoUrl;

    // If no photo is selected, use a default placeholder URL or handle it appropriately
    if (_bridePhoto == null) {
      bridePhotoUrl =
          "https://media.istockphoto.com/id/612650934/vector/id-card-isolated-on-white-background-business-identification-icon.jpg?s=612x612&w=0&k=20&c=byimQb2_LJydS803qrpYKk-80dIC4HEp-BidObosij0="; // Default placeholder image path
    } else {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Upload the selected photo to Firebase Storage
        bridePhotoUrl = await _IDCard(_bridePhoto!, 'idcard');
        Navigator.pop(context); // Close the loading indicator
      } catch (e) {
        Navigator.pop(context); // Close the loading indicator
        _showAlert('Failed to upload id card. Please try again.');
        return;
      }
    }

    // Save the photo URL or default to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'idCard': bridePhotoUrl,
      });

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => const MainDashboard()),
      );
    } catch (e) {
      _showAlert('Failed to save photo. Please try again.');
    }
  }

  Future<String> _IDCard(File file, String photoType) async {
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
              "Upload photos of your id card.",
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
                    onTap: () => _pickImage(true),
                    child: _buildPhotoTile(
                        image: _bridePhoto != null
                            ? FileImage(_bridePhoto!)
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
