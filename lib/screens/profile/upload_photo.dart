import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/widgets/save_button.dart';

class UploadPhoto extends StatefulWidget {
  const UploadPhoto({super.key});

  @override
  State<UploadPhoto> createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
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
      bridePhotoUrl = "assets/logo.png"; // Default placeholder image path
    } else {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Upload the selected photo to Firebase Storage
        bridePhotoUrl = await _uploadPhoto(_bridePhoto!, 'bridePhoto');
        Navigator.pop(context); // Close the loading indicator
      } catch (e) {
        Navigator.pop(context); // Close the loading indicator
        _showAlert('Failed to upload photo. Please try again.');
        return;
      }
    }

    // Save the photo URL or default to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'image': bridePhotoUrl,
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
                'Upload Photos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Upload photos for the bride and groom.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  const Text('Bride Photo'),
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
