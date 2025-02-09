import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/auth/login_screen.dart';
import 'package:muslim_mariage/screens/auth/signup_screen.dart';
import 'package:muslim_mariage/utils/colors.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Match Profile",
      "description":
          "Find your perfect match with our intelligent profile matching system.",
      "image": "assets/profile_match.png"
    },
    {
      "title": "Chat",
      "description":
          "Communicate securely with potential matches using our chat feature.",
      "image": "assets/chat.png"
    },
    {
      "title": "Security & Payment",
      "description":
          "Enjoy a safe and secure experience with our trusted payment system.",
      "image": "assets/pay.png"
    },
    {
      "title": "Video Call",
      "description":
          "Enhance your profile with video introductions for better connections.",
      "image": "assets/video_call.png"
    },
  ];

  void _onNext() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  void _onSkip() {
    _onSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingContent(
                  title: onboardingData[index]['title']!,
                  description: onboardingData[index]['description']!,
                  image: onboardingData[index]['image']!,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? colorWhite : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _currentPage == onboardingData.length - 1
                ? ElevatedButton(
                    onPressed: _onSignIn,
                    child: const Text("Create Account Free"),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _onSkip,
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: colorWhite),
                        ),
                      ),
                      TextButton(
                        onPressed: _onNext,
                        child: const Text(
                          "Next",
                          style: TextStyle(color: colorWhite),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 250, fit: BoxFit.cover),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Updated color
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70, // Updated color
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
