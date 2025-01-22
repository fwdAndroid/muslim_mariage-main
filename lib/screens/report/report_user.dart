import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/utils/showmesssage.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:uuid/uuid.dart';

class ReportUser extends StatefulWidget {
  final String FriendName;
  final String FriendID;

  ReportUser({super.key, required this.FriendName, required this.FriendID});

  @override
  State<ReportUser> createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;
  bool hasReported = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserReported();
  }

  // Check if the current user has already reported the friend
  Future<void> _checkIfUserReported() async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final reportSnapshot = await FirebaseFirestore.instance
        .collection("report")
        .where("reporterId", isEqualTo: currentUserID)
        .where("reportedId", isEqualTo: widget.FriendID)
        .get();

    if (reportSnapshot.docs.isNotEmpty) {
      setState(() {
        hasReported = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.045;
    var uuid = Uuid().v4();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Reports'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          var snap = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Users',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Type your message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  enabled: !hasReported,
                ),
                const SizedBox(height: 16),
                const Spacer(),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SaveButton(
                        onTap: hasReported
                            ? null
                            : () async {
                                if (_messageController.text.isEmpty) {
                                  showMessageBar(
                                      "Please enter your message", context);
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                await FirebaseFirestore.instance
                                    .collection("report")
                                    .doc(uuid)
                                    .set({
                                  "message": _messageController.text,
                                  "timestamp": DateTime.now(),
                                  "uuid": uuid,
                                  "email": snap['email'],
                                  "name": snap['fullName'],
                                  "status": "pending",
                                  "reporterId":
                                      FirebaseAuth.instance.currentUser!.uid,
                                  "reportedId": widget.FriendID,
                                });

                                setState(() {
                                  _messageController.clear();
                                  isLoading = false;
                                  hasReported = true;
                                });

                                showMessageBar(
                                    "Complaint sent to admin", context);
                              },
                        title: hasReported ? "Already Reported" : "Send",
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
