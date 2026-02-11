import 'package:flutter/material.dart';
import 'package:onboard/screens/main_layout_navbar.dart';
import 'package:onboard/screens/welcome_screen.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Share Your Projects",
      "subtitle": "Upload and show the world your innovation",
      "image": "assets/images/welcome_1.jpg",
    },
    {
      "title": "Connect & Collaborate",
      "subtitle": "Work together to bring your ideas to life",
      "image": "assets/images/welcome_2.jpg",
    },
    {
      "title": "Grow with Feedback",
      "subtitle":
          "Get reviews, support, and funding that help you reach new heights",
      "image": "assets/images/welcome_3.jpg",
    },
  ];

  void nextPage() {
    if (currentPage == onboardingData.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white, Color(0xff7E9FCA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainLayoutNavbar(),
                      ),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            onboardingData[index]["image"]!,
                            height: 160,
                            width: 169,
                          ),
                          const SizedBox(height: 40),

                          SizedBox(
                            width: 183,
                            height: 84,
                            child: Text(
                              onboardingData[index]["title"]!,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                                height: 1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            width: 250,
                            height: 56,
                            child: Text(
                              onboardingData[index]["subtitle"]!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: index == 3 ? 4 : 3,
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
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
                    margin: const EdgeInsets.symmetric(horizontal: 13),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? const Color(0xff1E3A8A)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1E3A8A),
                    minimumSize: const Size(329, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: nextPage,
                  child: Text(
                    currentPage == onboardingData.length - 1 ? "START" : "NEXT",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
