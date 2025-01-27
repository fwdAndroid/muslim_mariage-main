import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/functions.dart';
import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/screens/report/report_user.dart';
import 'package:muslim_mariage/utils/colors.dart';

class ViewAll extends StatefulWidget {
  const ViewAll({super.key});

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  String _currentUserGender = '';

  Future<void> _fetchCurrentUserGender() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _currentUserGender = doc.data()?['gender'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchCurrentUserGender();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where("gender",
                isEqualTo: _currentUserGender == 'Male' ? 'Female' : 'Male')
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

          var userDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data =
                  userDocs[index].data() as Map<String, dynamic>;

              // Parse DOB in "DD/MM/YY" format
              final dob = data['dob'] ?? '';
              DateTime? birthday;
              try {
                final parts = dob.split('/');
                if (parts.length == 3) {
                  int day = int.parse(parts[0]);
                  int month = int.parse(parts[1]);
                  int year = int.parse(parts[2]);

                  // Correctly handle two-digit years
                  if (year < 100) {
                    final currentYear = DateTime.now().year %
                        100; // Last two digits of current year
                    year += (year > currentYear ? 1900 : 2000);
                  }

                  birthday = DateTime(year, month, day);
                }
              } catch (e) {
                debugPrint('Invalid date format: $dob');
              }

              final age = birthday != null
                  ? RegisterFunctions().calculateAge(birthday)
                  : 'Invalid DOB';

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
                          ),
                        ),
                      );
                    },
                    child: Text("Report User"),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => ProfileDetail(
                          location: data['location'],
                          friendPhoto: data['image'],
                          friendName: data['fullName'],
                          friendId: data['uid'],
                          friendDOB: age ?? "Not Available",
                          gender: data['gender'],
                          sect: data['sect'] ?? "Not Available",
                          cast: data['cast'] ?? "Not Available",
                          friendPhone: data['contactNumber'] ?? "Not Available",
                          maritalStatus: data['maritalStatus'],
                          friendQualification:
                              data['qualification'] ?? "Not Available",
                          yourSelf: data['aboutYourself'] ?? "Not Available",
                          friendMother: data['motherName'] ?? "Not Available",
                          friendFather: data['fatherName'] ?? "Not Available",
                          profileCreator: data['profileCreator'],
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['image']),
                  ),
                  title: Text(data['fullName'] ?? 'No Name'),
                  subtitle: Text(
                      '${data['email'] ?? 'No Email'} | Age: $age'), // Displaying age
                ),
              );
            },
          );
        },
      ),
    );
  }
}
