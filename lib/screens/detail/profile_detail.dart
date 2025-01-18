import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/chat/message.dart';
import 'package:muslim_mariage/screens/report/report_user.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class ProfileDetail extends StatefulWidget {
  String yourSelf;
  String friendPhone;
  String friendQualification;
  String friendDOB;
  String friendPhoto;
  String friendName;
  String friendId;
  String sect;
  String cast;
  String gender;
  ProfileDetail(
      {super.key,
      required this.yourSelf,
      required this.friendId,
      required this.friendName,
      required this.friendPhoto,
      required this.friendPhone,
      required this.friendDOB,
      required this.friendQualification,
      required this.sect,
      required this.gender,
      required this.cast});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  var uuid = const Uuid().v4();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<Object>(
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
                Stack(
                  children: [
                    Image.network(
                      widget.friendPhoto,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      height: 200,
                      filterQuality: FilterQuality.high,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: black,
                          )),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Profile Description",
                    style: TextStyle(
                        color: black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.yourSelf,
                    style: TextStyle(
                        color: black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SaveButton(
                        title: "Chat Now",
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("chats")
                              .doc(uuid)
                              .set({
                            "friendName": widget.friendName,
                            "friendId": widget.friendId,
                            "friendImage": widget.friendPhoto,
                            "chatId": uuid,
                            "userName": snap['fullName'],
                            "userId": FirebaseAuth.instance.currentUser!.uid,
                            "userPhoto": snap['image'],
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => Messages(
                                        userPhoto: snap['image'],
                                        friendName: widget.friendName,
                                        chatId: uuid,
                                        friendId: widget.friendId,
                                        friendImage: widget.friendPhoto,
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        userName: snap['fullName'],
                                      )));
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
                                  builder: (builder) => ReportUser()));
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
    );
  }

  Widget _buildTextField(String labelText, IconData? icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
      ),
    );
  }
}
