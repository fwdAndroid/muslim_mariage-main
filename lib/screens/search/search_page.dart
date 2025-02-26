import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/functions.dart';
import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/screens/search/advanced_search.dart';
import 'package:muslim_mariage/utils/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _emailController = TextEditingController();
  String _searchText = '';
  String _currentUserGender = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUserGender();
  }

  Future<void> _getCurrentUserGender() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      setState(() {
        _currentUserGender = userDoc['gender'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => AdvancedSearch()));
            },
            child: Text(
              "Advanced Search",
              style: TextStyle(color: mainColor),
            ),
          )
        ],
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
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
          ),
          Expanded(
            child: _searchText.isEmpty
                ? Center(
                    child: Text(
                      "Please enter a search query",
                      style: TextStyle(color: black),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("gender", isNotEqualTo: _currentUserGender)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final fullName = data['fullName'] ?? '';
                        final castName = data['cast'] ?? '';
                        final sectName = data['sect'] ?? '';
                        final professionName = data['qualification'] ?? '';
                        final searchLower = _searchText.toLowerCase();

                        // Ensure the current user's own document is excluded
                        if (data['uid'] == userId) {
                          return false;
                        }

                        return fullName.toLowerCase().contains(searchLower) ||
                            castName.toLowerCase().contains(searchLower) ||
                            sectName.toLowerCase().contains(searchLower) ||
                            professionName.toLowerCase().contains(searchLower);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            "No Results Found",
                            style: TextStyle(color: black),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final data = filteredDocs[index].data()
                              as Map<String, dynamic>;
                          final dob = data['dob'] ?? '';
                          DateTime? birthday = parseDob(dob);

                          final age = birthday != null
                              ? calculateAge(birthday)
                              : "Unknown";
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(8)),
                                    child: Image.network(
                                      data['image'] ?? '', // Handle null safely
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['fullName'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(data['dob'] ?? 'Unknown'),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (builder) => ProfileDetail(
                                                  height: data['height'],
                                                  idCard: data['idCard'],
                                                  salary: data['salary'],
                                                  friendMother:
                                                      data['motherName'] ??
                                                          "Not Available",
                                                  friendFather:
                                                      data['fatherName'] ??
                                                          "Not Available",
                                                  jobOccupation:
                                                      data['jobOccupation'],
                                                  profileCreator:
                                                      data['profileCreator'],
                                                  maritalStatus:
                                                      data['maritalStatus'],
                                                  location: data['location'],
                                                  friendPhoto: data['image'] ??
                                                      "https://cdn.pixabay.com/photo/2024/05/26/10/15/bird-8788491_960_720.jpg",
                                                  friendName: data['fullName'],
                                                  friendId: data['uid'],
                                                  friendDOB: age,
                                                  gender: data['gender'],
                                                  sect: data['sect'] ??
                                                      "Not Available",
                                                  cast: data['cast'] ??
                                                      "Not Available",
                                                  friendPhone:
                                                      data[
                                                              'contactNumber'] ??
                                                          "Not Available",
                                                  friendQualification:
                                                      data['qualification'] ??
                                                          "Not Available",
                                                  yourSelf:
                                                      data['aboutYourself'] ??
                                                          "Not Available"),
                                            ),
                                          );
                                        },
                                        child: Icon(Icons.arrow_forward,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

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
