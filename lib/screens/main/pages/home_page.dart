import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/screens/detail/view_all.dart';
import 'package:muslim_mariage/screens/search/search_page.dart';
import 'package:muslim_mariage/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _emailController = TextEditingController();
  String _searchText = '';
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String _currentUserGender = '';
  Map<String, dynamic> _currentUserData = {};
  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _searchText = _emailController.text;
      });
    });
    _fetchCurrentUserGender();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            "Find Your Match ?",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => const SearchPage()));
                },
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Best Match",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const ViewAll()));
                    },
                    child: const Text("View all"),
                  ),
                ],
              ),
              SizedBox(
                height: 460,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("uid",
                          isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where("gender",
                          isEqualTo:
                              _currentUserGender == 'Male' ? 'Female' : 'Male')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No User Available",
                          style: TextStyle(color: black),
                        ),
                      );
                    }

                    final filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      // 1. Search filter
                      final searchLower = _searchText.toLowerCase();
                      final matchesSearch = [
                        data['fullName']?.toString().toLowerCase() ?? '',
                        data['cast']?.toString().toLowerCase() ?? '',
                        data['sect']?.toString().toLowerCase() ?? '',
                        data['qualification']?.toString().toLowerCase() ?? '',
                      ].any((field) => field.contains(searchLower));

                      // 2. Blocking filter (NEW IMPROVED VERSION)
                      final blockedUsers = List<String>.from(
                          data['blocked']?.map((e) => e.toString()) ?? []);
                      final currentUserIsBlocked =
                          blockedUsers.contains(currentUserId);

                      // 3. Reverse blocking filter (NEW ADDITION)
                      final myBlockedUsers =
                          List<String>.from(_currentUserData['blocked'] ?? []);
                      final iHaveBlockedThisUser =
                          myBlockedUsers.contains(data['uid']);

                      return matchesSearch &&
                          !currentUserIsBlocked &&
                          !iHaveBlockedThisUser;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Results Found",
                          style: TextStyle(color: black),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final Map<String, dynamic> data =
                            filteredDocs[index].data() as Map<String, dynamic>;

                        // Validate and parse 'dob'
                        final dob = data['dob'] ?? '';
                        DateTime? birthday = parseDob(dob);

                        final age = birthday != null
                            ? calculateAge(birthday)
                            : "Unknown";

                        final List<dynamic> favorites = data['favorite'] ?? [];
                        final List<dynamic> stars = data['star'] ?? [];
                        bool isFavorite = favorites.contains(currentUserId);
                        bool isStar = stars.contains(currentUserId);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ProfileDetail(
                                        height: data['height'],
                                        idCard: data['idCard'],
                                        salary: data['salary'],
                                        friendMother: data['motherName'] ??
                                            "Not Available",
                                        friendFather: data['fatherName'] ??
                                            "Not Available",
                                        profileCreator: data['profileCreator'],
                                        maritalStatus: data['maritalStatus'],
                                        friendPhoto: data['image'],
                                        friendName: data['fullName'],
                                        friendId: data['uid'],
                                        friendDOB: age,
                                        jobOccupation: data['jobOccupation'],
                                        gender: data['gender'],
                                        sect: data['sect'] ?? "Not Available",
                                        cast: data['cast'] ?? "Not Available",
                                        location: data['location'],
                                        friendPhone: data['contactNumber'] ??
                                            "Not Available",
                                        friendQualification:
                                            data['qualification'] ??
                                                "Not Available",
                                        yourSelf: data['aboutYourself'] ??
                                            "Not Available")));
                          },
                          child: SizedBox(
                            height: 400,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: data['image'] == null ||
                                              data['image'].isEmpty
                                          ? Image.asset(
                                              "assets/logo.png",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                          : Image.network(
                                              data['image'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child; // Image is loaded, return the image
                                                } else {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              (loadingProgress
                                                                      .expectedTotalBytes ??
                                                                  1)
                                                          : null,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.4),
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${data['fullName']}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '$age yrs',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                data['sect'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                data['cast'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                data['maritalStatus'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                data['location'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Favorite Icon
                                                    IconButton(
                                                      iconSize: 50,
                                                      onPressed: () async {
                                                        final docRef =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "users")
                                                                .doc(data[
                                                                    'uid']);

                                                        if (isFavorite) {
                                                          await docRef.update({
                                                            "favorite": FieldValue
                                                                .arrayRemove([
                                                              currentUserId
                                                            ]),
                                                          });

                                                          setState(() {
                                                            isFavorite = false;
                                                          });

                                                          Fluttertoast
                                                              .showToast(
                                                            backgroundColor:
                                                                red,
                                                            msg:
                                                                "Removed ${data['fullName']} from your favorite list",
                                                            textColor:
                                                                colorWhite,
                                                          );
                                                        } else {
                                                          await docRef.update({
                                                            "favorite":
                                                                FieldValue
                                                                    .arrayUnion([
                                                              currentUserId
                                                            ]),
                                                          });

                                                          setState(() {
                                                            isFavorite = true;
                                                          });

                                                          Fluttertoast
                                                              .showToast(
                                                            backgroundColor:
                                                                mainColor,
                                                            msg:
                                                                "Added ${data['fullName']} to your favorite list",
                                                            textColor:
                                                                colorWhite,
                                                          );
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.favorite,
                                                        color: isFavorite
                                                            ? Colors.red
                                                            : iconColor,
                                                      ),
                                                    ),
                                                    // Star Icon
                                                    IconButton(
                                                      iconSize: 40,
                                                      onPressed: () async {
                                                        final docRef =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "users")
                                                                .doc(data[
                                                                    'uid']);

                                                        if (isStar) {
                                                          await docRef.update({
                                                            "star": FieldValue
                                                                .arrayRemove([
                                                              currentUserId
                                                            ]),
                                                          });

                                                          setState(() {
                                                            isStar = false;
                                                          });

                                                          Fluttertoast
                                                              .showToast(
                                                            backgroundColor:
                                                                red,
                                                            msg:
                                                                "Removed ${data['fullName']} from your star list",
                                                            textColor:
                                                                colorWhite,
                                                          );
                                                        } else {
                                                          await docRef.update({
                                                            "star": FieldValue
                                                                .arrayUnion([
                                                              currentUserId
                                                            ]),
                                                          });

                                                          setState(() {
                                                            isStar = true;
                                                          });

                                                          Fluttertoast
                                                              .showToast(
                                                            backgroundColor:
                                                                mainColor,
                                                            msg:
                                                                "Added ${data['fullName']} to your star list",
                                                            textColor:
                                                                colorWhite,
                                                          );
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.star,
                                                        color: isStar
                                                            ? Colors.yellow
                                                            : iconColor,
                                                      ),
                                                    ),
                                                    // Chat Icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (builder) => ProfileDetail(
                                                                    height: data[
                                                                        'height'],
                                                                    idCard: data[
                                                                        'idCard'],
                                                                    salary: data[
                                                                        'salary'],
                                                                    friendMother:
                                                                        data['motherName'] ??
                                                                            "Not Available",
                                                                    friendFather:
                                                                        data['fatherName'] ??
                                                                            "Not Available",
                                                                    profileCreator:
                                                                        data[
                                                                            'profileCreator'],
                                                                    maritalStatus:
                                                                        data[
                                                                            'maritalStatus'],
                                                                    friendPhoto:
                                                                        data[
                                                                            'image'],
                                                                    friendName:
                                                                        data[
                                                                            'fullName'],
                                                                    friendId:
                                                                        data[
                                                                            'uid'],
                                                                    friendDOB:
                                                                        age,
                                                                    jobOccupation:
                                                                        data['jobOccupation'],
                                                                    gender: data['gender'],
                                                                    sect: data['sect'] ?? "Not Available",
                                                                    cast: data['cast'] ?? "Not Available",
                                                                    location: data['location'],
                                                                    friendPhone: data['contactNumber'] ?? "Not Available",
                                                                    friendQualification: data['qualification'] ?? "Not Available",
                                                                    yourSelf: data['aboutYourself'] ?? "Not Available")));
                                                      },
                                                      child: Image.asset(
                                                          "assets/icons8-chat-48.png",
                                                          height: 40),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _fetchCurrentUserGender() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    if (doc.exists) {
      setState(() {
        _currentUserGender = doc.data()?['gender'] ?? '';
        _currentUserData = doc.data() ?? {};
      });
    }
  }

  // Parsing DOB string to DateTime, considering two-digit years.
  DateTime? parseDob(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        // Handle two-digit years
        if (year < 100) {
          final currentYear = DateTime.now().year % 100;
          year += (year > currentYear ? 1900 : 2000);
        }

        return DateTime(year, month, day);
      }
    } catch (e) {
      // Handle invalid date parsing
      return null;
    }
    return null;
  }

  // Function to calculate the user's age from the parsed birthday.
  String calculateAge(DateTime birthday) {
    final DateTime today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age.toString();
  }
}
