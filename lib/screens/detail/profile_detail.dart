import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  String maritalStatus;
  String cast;
  String location;
  String gender;
  ProfileDetail(
      {super.key,
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
      required this.cast});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  var uuid = const Uuid().v4();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: StreamBuilder<Object>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text(""));
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
                            ))
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
                                  widget.friendPhone,
                                  style: TextStyle(
                                    color: black,
                                    fontSize: 16,
                                  ),
                                ),
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
                              buildDetailRow(
                                  "Father Name", widget.friendFather),
                              buildDetailRow(
                                  "Mother Name", widget.friendMother),
                              buildDetailRow('Sect', widget.sect),
                              buildDetailRow('Cast', widget.cast),
                              buildDetailRow('Age', widget.friendDOB + " yrs"),
                              buildDetailRow('Gender', widget.gender),
                              buildDetailRow(
                                  'Marital Status', widget.maritalStatus),
                            ],
                          ),
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
                                  'Qualification',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  widget.friendQualification,
                                  style: TextStyle(
                                    color: black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Created By',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  widget.profileCreator,
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
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: mainColor,
                            ),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SaveButton(
                                  title: "Send Chat Request",
                                  onTap: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    Fluttertoast.showToast(
                                        msg:
                                            "Chat Request Sent to ${widget.friendName}",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: mainColor,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    await FirebaseFirestore.instance
                                        .collection("chats")
                                        .doc(uuid)
                                        .set({
                                      "friendName": widget.friendName,
                                      "friendId": widget.friendId,
                                      "friendImage": widget.friendPhoto,
                                      "chatId": uuid,
                                      "userName": snap['fullName'],
                                      "userId": FirebaseAuth
                                          .instance.currentUser!.uid,
                                      "userPhoto": snap['image'],
                                      "isAccepted": false,
                                    });

                                    setState(() {
                                      isLoading = false;
                                    });

                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (builder) => Messages(
                                    //               userPhoto: snap['image'],
                                    //               friendName: widget.friendName,
                                    //               chatId: uuid,
                                    //               friendId: widget.friendId,
                                    //               friendImage: widget.friendPhoto,
                                    //               userId: FirebaseAuth
                                    //                   .instance.currentUser!.uid,
                                    //               userName: snap['fullName'],
                                    //             )));
                                  }),
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
                                          )));
                            },
                            child: Text(
                              "Report Account",
                              style: TextStyle(color: mainColor),
                            )),
                      ),
                    )
                  ],
                );
              }),
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
