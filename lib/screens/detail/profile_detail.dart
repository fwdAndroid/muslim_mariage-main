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

class _ProfileDetailState extends State<ProfileDetail>
    with SingleTickerProviderStateMixin {
  var uuid = const Uuid().v4();
  bool isLoading = false;
  String _userStatus = '';
  bool hasPendingRequest = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        hasPendingRequest = !chatData['isAccepted'];
      });
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
        appBar: AppBar(
          iconTheme: IconThemeData(color: colorWhite),
          centerTitle: true,
          backgroundColor: mainColor,
          title: Text(
            "Profile Information",
            style: TextStyle(color: colorWhite),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: colorWhite,
            unselectedLabelColor: black,
            tabs: [
              Tab(text: "Basic Info"),
              Tab(text: "Professional"),
              Tab(text: "Photos"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildBasicInfo(),
            buildProfessionalDetails(),
            buildIdCardAndPhoto(),
          ],
        ),
        bottomNavigationBar: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, AsyncSnapshot snapshot) {
              var snap = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                        msg:
                                            "You are not verified by the admin.",
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
                    TextButton(
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
                      child: Text("Report Account",
                          style: TextStyle(color: mainColor)),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget buildBasicInfo() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                buildDetailRow('Name', widget.friendName),
                buildDetailRow("Father Name", widget.friendFather),
                buildDetailRow("Mother Name", widget.friendMother),
                buildDetailRow('Sect', widget.sect),
                buildDetailRow('Cast', widget.cast),
                buildDetailRow('Age', widget.friendDOB + " yrs"),
                buildDetailRow('Height', widget.height),
                buildDetailRow('Gender', widget.gender),
                buildDetailRow('Marital Status', widget.maritalStatus),
              ],
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
      ],
    );
  }

  Widget buildProfessionalDetails() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        Card(
          child: Column(children: [
            buildDetailRow('Qualification', widget.friendQualification),
            buildDetailRow('Job', widget.jobOccupation),
            buildDetailRow('Salary', widget.salary),
          ]),
        ),
      ],
    );
  }

  Widget buildIdCardAndPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Photo",
          style: TextStyle(
              color: mainColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.friendPhoto,
                  height: 200,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width),
            ),
          ),
        ),
        Text(
          "ID Card",
          style: TextStyle(
              color: mainColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.idCard,
                  height: 200,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
