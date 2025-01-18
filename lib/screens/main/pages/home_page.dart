import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                    // View all action
                  },
                  child: Text("View all"),
                ),
              ],
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ProfileDetail(
                                      friendPhoto: data['image'],
                                      friendName: data['fullName'],
                                      friendId: data['uid'],
                                      image: data['image'],
                                      yourSelf: data['aboutYourself'])));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  child: Image.network(
                                    data['image'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                                          data['fullName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(data['dob']),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    ProfileDetail(
                                                        friendPhoto:
                                                            data['image'],
                                                        friendName:
                                                            data['fullName'],
                                                        friendId: data['uid'],
                                                        image: data['image'],
                                                        yourSelf: data[
                                                            'aboutYourself'])));
                                      },
                                      child: Icon(Icons.arrow_forward,
                                          color: Colors.black),
                                    ),
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
    );
  }
}
