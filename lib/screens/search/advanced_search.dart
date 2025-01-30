import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/detail/profile_detail.dart';
import 'package:muslim_mariage/widgets/save_button.dart';

class AdvancedSearch extends StatefulWidget {
  const AdvancedSearch({super.key});

  @override
  State<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  final TextEditingController castController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    castController.addListener(_clearResultsIfNeeded);
    ageController.addListener(_clearResultsIfNeeded);
    cityController.addListener(_clearResultsIfNeeded);
  }

  @override
  void dispose() {
    castController.dispose();
    ageController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void _clearResultsIfNeeded() {
    if (castController.text.isEmpty &&
        ageController.text.isEmpty &&
        cityController.text.isEmpty) {
      setState(() {
        searchResults.clear();
      });
    }
  }

  /// Convert input to lowercase for case-insensitive search
  String toLowerCaseTrim(String value) {
    return value.trim().toLowerCase();
  }

  /// Calculates age from the DOB (format: `DD/MM/YY` or `DD/MM/YYYY`)
  int calculateAge(String dob) {
    try {
      List<String> parts = dob.split('/');
      if (parts.length == 3) {
        int year = int.parse(parts[2]); // Get year (YY or YYYY)
        if (year < 100) {
          year += 1900; // Convert YY to full year (1995, 1996, etc.)
        }
        DateTime birthDate =
            DateTime(year, int.parse(parts[1]), int.parse(parts[0]));
        int age = DateTime.now().year - birthDate.year;
        return age;
      }
    } catch (e) {
      print("Error parsing DOB: $dob");
    }
    return 0; // Default age if parsing fails
  }

  /// Firestore Search by Age & Case-Insensitive Search
  void searchFirestore() async {
    if (castController.text.isEmpty &&
        ageController.text.isEmpty &&
        cityController.text.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> filteredResults = snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((user) {
      bool matchesCast = castController.text.isEmpty ||
          (user['cast']?.toString().toLowerCase() ?? '')
              .contains(toLowerCaseTrim(castController.text));

      bool matchesCity = cityController.text.isEmpty ||
          (user['location']?.toString().toLowerCase() ?? '')
              .contains(toLowerCaseTrim(cityController.text));

      bool matchesAge = true;
      if (ageController.text.isNotEmpty) {
        try {
          int inputAge = int.parse(ageController.text.trim());
          int userAge = user['dob'] != null ? calculateAge(user['dob']) : 0;
          matchesAge = userAge == inputAge;
        } catch (e) {
          matchesAge = false;
        }
      }

      return matchesCast && matchesCity && matchesAge;
    }).toList();

    setState(() {
      searchResults = filteredResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextField(
            controller: castController,
            decoration: InputDecoration(labelText: "Enter Cast"),
          ),
          TextField(
            controller: ageController,
            decoration: InputDecoration(labelText: "Enter Age"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: cityController,
            decoration: InputDecoration(labelText: "Enter City"),
          ),
          SizedBox(height: 16),
          SaveButton(
            onTap: searchFirestore,
            title: "Search",
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var user = searchResults[index];
                int age = user['dob'] != null ? calculateAge(user['dob']) : 0;
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => ProfileDetail(
                            location: user['location'],
                            height: user['height'],
                            idCard: user['idCard'],
                            salary: user['salary'],
                            friendPhoto: user['image'],
                            friendName: user['fullName'],
                            friendId: user['uid'],
                            jobOccupation: user['jobOccupation'],
                            friendDOB: age.toString(),
                            gender: user['gender'],
                            sect: user['sect'] ?? "Not Available",
                            cast: user['cast'] ?? "Not Available",
                            friendPhone:
                                user['contactNumber'] ?? "Not Available",
                            maritalStatus: user['maritalStatus'],
                            friendQualification:
                                user['qualification'] ?? "Not Available",
                            yourSelf: user['aboutYourself'] ?? "Not Available",
                            friendMother: user['motherName'] ?? "Not Available",
                            friendFather: user['fatherName'] ?? "Not Available",
                            profileCreator: user['profileCreator'],
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['image']),
                    ),
                    title: Text(user['fullName'] ?? "No Name"),
                    subtitle: Text(
                        "Cast: ${user['cast']}, City: ${user['location']}, Age: $age"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
