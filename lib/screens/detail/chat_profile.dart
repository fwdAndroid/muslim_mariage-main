import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/report/report_user.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:uuid/uuid.dart';

class ChatProfile extends StatefulWidget {
  String friendId;

  ChatProfile({
    super.key,
    required this.friendId,
  });

  @override
  State<ChatProfile> createState() => _ChatProfileState();
}

class _ChatProfileState extends State<ChatProfile> {
  Map<String, dynamic>? friendData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriendDetails();
  }

  Future<void> _fetchFriendDetails() async {
    try {
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.friendId)
          .get();

      if (friendDoc.exists) {
        setState(() {
          friendData = friendDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching friend details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show loader while fetching
                : SingleChildScrollView(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture and Name
                      Stack(
                        children: [
                          Image.network(
                            friendData!['image'],
                            height: 200,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close,
                              color: black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Contact Details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Profile Description",
                          style: TextStyle(
                            color: black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 8, right: 8, top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact Number:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    friendData!['contactNumber'],
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Location:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    friendData!['location'],
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Basic Details
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Basic Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                buildDetailRow(
                                  'Name',
                                  friendData!['fullName'],
                                ),
                                buildDetailRow(
                                  "Father Name",
                                  friendData!['fatherName'],
                                ),
                                buildDetailRow(
                                  "Mother Name",
                                  friendData!['motherName'],
                                ),
                                buildDetailRow(
                                  'Sect',
                                  friendData!['sect'],
                                ),
                                buildDetailRow(
                                  'Cast',
                                  friendData!['cast'],
                                ),
                                buildDetailRow(
                                  'Age',
                                  friendData!['dob'],
                                ),
                                buildDetailRow(
                                  'Height',
                                  friendData!['height'],
                                ),
                                buildDetailRow(
                                  'Gender',
                                  friendData!['gender'],
                                ),
                                buildDetailRow('Marital Status',
                                    friendData!['maritalStatus']),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //About Yourself
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About User',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      friendData!['aboutYourself'],
                                      style: TextStyle(
                                        color: black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                      // Additional Information
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildDetailRow(
                                    'Qualification',
                                    friendData!['qualification'],
                                  ),
                                  buildDetailRow(
                                    'Job',
                                    friendData!['jobOccupation'],
                                  ),
                                  buildDetailRow(
                                    'Salary',
                                    friendData!['salary'],
                                  ),
                                  buildDetailRow(
                                    'Profile Created By',
                                    friendData!['profileCreator'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))));
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
