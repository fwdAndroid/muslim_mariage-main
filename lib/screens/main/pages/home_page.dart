import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mariage/functions.dart';
import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/screens/detail/view_all.dart';
import 'package:muslim_mariage/screens/search/search_page.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _emailController = TextEditingController();
  String _searchText = '';
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _searchText = _emailController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => SearchPage()));
              },
              controller: _emailController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Best Match",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => ViewAll()));
                  },
                  child: Text("View all"),
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

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    final fullName = data['fullName'] as String? ?? '';
                    final caste = data['cast'] as String? ?? '';
                    final sect = data['sect'] as String? ?? '';
                    final profession = data['qualification'] as String? ?? '';

                    final searchLower = _searchText.toLowerCase();

                    return fullName.toLowerCase().contains(searchLower) ||
                        caste.toLowerCase().contains(searchLower) ||
                        sect.toLowerCase().contains(searchLower) ||
                        profession.toLowerCase().contains(searchLower);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        "No Results Found",
                        style: TextStyle(color: black),
                      ),
                    );
                  }

                  return CardSwiper(
                    cardsCount: filteredDocs.length,
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                      final Map<String, dynamic> data =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final birthday = DateTime.parse(data['dob']);
                      final age = RegisterFunctions().calculateAge(birthday);
                      final List<dynamic> favorites = data['favorite'] ?? [];
                      bool isFavorite = favorites.contains(currentUserId);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ProfileDetail(
                                      friendMother:
                                          data['motherName'] ?? "Not Available",
                                      friendFather:
                                          data['fatherName' ?? "Not Available"],
                                      profileCreator: data['profileCreator'],
                                      maritalStatus: data['maritalStatus'],
                                      friendPhoto: data['image'] ??
                                          "https://cdn.pixabay.com/photo/2024/05/26/10/15/bird-8788491_960_720.jpg",
                                      friendName: data['fullName'],
                                      friendId: data['uid'],
                                      friendDOB: age,
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
                        child: Card(
                          color: colorWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  child: data['image'] == null ||
                                          data['image'].isEmpty
                                      ? Image.asset("assets/logo.png",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity)
                                      : Image.network(data['image'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data['fullName']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        color: black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$age yrs',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      data['sect'] + (" Islam"),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      data['maritalStatus'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      data['location'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Center(
                                      child: IconButton(
                                        iconSize: 50,
                                        onPressed: () async {
                                          final docRef = FirebaseFirestore
                                              .instance
                                              .collection("users")
                                              .doc(data[
                                                  'uid']); // Reference the user document

                                          // Check if the item is marked as favorite
                                          if (isFavorite) {
                                            // If already favorited, remove current user ID from the favorites list
                                            await docRef.update({
                                              "favorite":
                                                  FieldValue.arrayRemove(
                                                      [currentUserId]),
                                            });

                                            setState(() {
                                              // Update local state to reflect the new favorite status
                                              isFavorite =
                                                  false; // Unmark as favorite
                                            });

                                            Fluttertoast.showToast(
                                              backgroundColor: red,
                                              msg:
                                                  "Removed ${data['fullName']} from your favorite list",
                                              textColor:
                                                  colorWhite, // Show a red toast message
                                            );
                                          } else {
                                            // If not favorited, add current user ID to the favorites list
                                            await docRef.update({
                                              "favorite": FieldValue.arrayUnion(
                                                  [currentUserId]),
                                            });

                                            setState(() {
                                              // Update local state to reflect the new favorite status
                                              isFavorite =
                                                  true; // Mark as favorite
                                            });

                                            Fluttertoast.showToast(
                                              backgroundColor: mainColor,
                                              msg:
                                                  "Added ${data['fullName']} to your favorite list",
                                              textColor:
                                                  colorWhite, // Show a green toast message
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: isFavorite
                                              ? Colors.red
                                              : iconColor, // Change icon color based on favorite status
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    scale: 0.9,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Delete Button at the bottom
    );
  }
}
