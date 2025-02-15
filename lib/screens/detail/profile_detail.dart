import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/main/main_dashboard.dart';
import 'package:muslim_mariage/screens/main/pages/home_page.dart';
import 'package:muslim_mariage/screens/report/report_user.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileDetail extends StatefulWidget {
  String yourSelf;
  String friendPhone;
  String friendQualification;
  String friendDOB;
  String friendPhoto;
  String friendName;
  String friendFather;
  String friendMother;
  String profileCreator;
  String friendId;
  String sect;
  String jobOccupation;
  String maritalStatus;
  String cast;
  String location;
  String gender;
  String idCard;
  String height;
  String salary;
  ProfileDetail({
    super.key,
    required this.yourSelf,
    required this.friendId,
    required this.friendName,
    required this.maritalStatus,
    required this.friendPhoto,
    required this.friendPhone,
    required this.friendDOB,
    required this.location,
    required this.friendQualification,
    required this.sect,
    required this.profileCreator,
    required this.friendFather,
    required this.friendMother,
    required this.gender,
    required this.height,
    required this.idCard,
    required this.salary,
    required this.jobOccupation,
    required this.cast,
  });

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  var uuid = const Uuid().v4();
  bool isLoading = false;
  String _userStatus = '';
  bool hasPendingRequest = false;
  bool isBlocked = false;
  @override
  void initState() {
    super.initState();
    _getCurrentUserStatus();
    _checkPendingRequest();
  }

  Future<void> _checkPendingRequest() async {
    final existingChatRequest = await FirebaseFirestore.instance
        .collection("chats")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("friendId", isEqualTo: widget.friendId)
        .get();

    if (existingChatRequest.docs.isNotEmpty) {
      final chatData = existingChatRequest.docs.first.data();
      setState(() {
        hasPendingRequest = !chatData['isAccepted']; // Check if it's pending
      });
    }
  }

  Future<void> blockUser() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc =
          FirebaseFirestore.instance.collection("users").doc(currentUserId);

      await userDoc.update({
        "blocked": FieldValue.arrayUnion([widget.friendId]),
      });

      setState(() {
        isBlocked = true;
      });

      Fluttertoast.showToast(
        backgroundColor: mainColor,
        msg: "${widget.friendName} has been blocked",
        textColor: Colors.white,
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (builder) => MainDashboard()));
    } catch (e) {
      print("Error blocking user: $e");
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: "Failed to block user",
        textColor: Colors.white,
      );
    }
  }

  Future<void> _getCurrentUserStatus() async {
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _userStatus = userDoc['status'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.none) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Loading'));
              }
              var snap = snapshot.data;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and Name
                  Stack(
                    children: [
                      Image.network(
                        widget.friendPhoto,
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
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
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
                              SizedBox(height: 8),
                              Text(
                                _userStatus == 'accepted'
                                    ? widget.friendPhone
                                    : 'Hidden (User not verified)',
                                style: TextStyle(
                                  color: black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Location:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.location,
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
                  TextButton(
                      onPressed: () async {
                        blockUser();
                      },
                      child: Text("Block")),
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
                            buildDetailRow('Name', widget.friendName),
                            buildDetailRow("Father Name", widget.friendFather),
                            buildDetailRow("Mother Name", widget.friendMother),
                            buildDetailRow('Sect', widget.sect),
                            buildDetailRow('Cast', widget.cast),
                            buildDetailRow('Age', widget.friendDOB + " yrs"),
                            buildDetailRow('Height', widget.height),
                            buildDetailRow('Gender', widget.gender),
                            buildDetailRow(
                                'Marital Status', widget.maritalStatus),
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
                                  widget.yourSelf,
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
                                  'Qualification', widget.friendQualification),
                              buildDetailRow('Job', widget.jobOccupation),
                              buildDetailRow('Salary', widget.salary),
                              buildDetailRow(
                                  'Profile Created By', widget.profileCreator),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  isLoading
                      ? const Center(
                          child: Text("Please wait"),
                        )
                      : hasPendingRequest
                          ? Center(
                              child: Text(
                                "Digital Rishta Bheja Gaya Hai.",
                                style: TextStyle(color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Center(
                              child: SaveButton(
                                onTap: () async {
                                  if (_userStatus == 'accepted') {
                                    setState(() {
                                      if (mounted) isLoading = true;
                                    });
                                    Fluttertoast.showToast(
                                      msg: "Digital Rishta Bheje",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                    );

                                    await FirebaseFirestore.instance
                                        .collection("chats")
                                        .doc(uuid)
                                        .set({
                                      "friendName": widget.friendName,
                                      "friendId": widget.friendId,
                                      "friendImage": widget.friendPhoto,
                                      "chatId": uuid,
                                      "userName": snap['fullName'],
                                      "userPhoto": snap['image'] ??
                                          "https://cdn.pixabay.com/photo/2024/05/26/10/15/bird-8788491_960_720.jpg",
                                      "userId": FirebaseAuth
                                          .instance.currentUser!.uid,
                                      "isAccepted": false,
                                    });

                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                        hasPendingRequest = true;
                                      });
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "You are not verified by the admin.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                  }
                                },
                                title: "Digital Rishta Bheje",
                              ),
                            ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => ReportUser(
                                FriendName: widget.friendName,
                                FriendID: widget.friendId,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Report Account",
                          style: TextStyle(color: mainColor),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
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
