import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/functions.dart';
import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/utils/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _emailController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

                if (_searchText.isEmpty) {
                  return Center(
                    child: Text(
                      "No Results Found",
                      style: TextStyle(color: black),
                    ),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = data['fullName'] ?? '';
                  final castName = data['cast'] ?? '';
                  final sectName = data['sect'] ?? '';
                  final professionName = data['qualification'] ?? '';
                  final searchLower = _searchText.toLowerCase();

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
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    final birthday = DateTime.parse(data['dob']);
                    final age = RegisterFunctions().calculateAge(birthday);
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            friendMother: data['motherName'] ??
                                                "Not Available",
                                            friendFather: data['fatherName' ??
                                                "Not Available"],
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
                                            sect:
                                                data['sect'] ?? "Not Available",
                                            cast:
                                                data['cast'] ?? "Not Available",
                                            friendPhone:
                                                data['contactNumber'] ??
                                                    "Not Available",
                                            friendQualification:
                                                data['qualification'] ??
                                                    "Not Available",
                                            yourSelf: data['aboutYourself'] ??
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
}
