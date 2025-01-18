import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/screens/report/report_user.dart';
import 'package:muslim_mariage/utils/colors.dart';

class ViewAll extends StatefulWidget {
  const ViewAll({super.key});

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("uid",
                    isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No User Available",
                    style: TextStyle(color: black),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("uid",
                          isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No users found.'));
                    }
                    var userDocs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: EdgeInsets.zero,

                      itemCount: userDocs.length, // For simplicity
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> data =
                            userDocs[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            trailing: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => ReportUser(
                                                FriendName: data['fullName'],
                                                FriendID: data['uid'],
                                              )));
                                },
                                child: Text("Report User")),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) => ProfileDetail(
                                      friendPhoto: data['image'] ??
                                          Image.asset("assets/logo.png"),
                                      friendName: data['fullName'],
                                      friendId: data['uid'],
                                      friendDOB: data['dob'] ?? "Not Available",
                                      gender: data['gender'],
                                      sect: data['sect'] ?? "Not Available",
                                      cast: data['cast'] ?? "Not Available",
                                      friendPhone: data['contactNumber'] ??
                                          "Not Available",
                                      friendQualification:
                                          data['qualification'] ??
                                              "Not Available",
                                      yourSelf: data['aboutYourself'] ??
                                          "Not Available"),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(data['image']),
                            ),
                            title: Text(data['fullName'] ?? 'No Name'),
                            subtitle: Text(data['email'] ?? 'No Email'),
                          ),
                        );
                      },
                    );
                  });
            }));
  }
}
