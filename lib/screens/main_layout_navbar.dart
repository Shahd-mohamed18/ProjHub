import 'package:flutter/material.dart';
import 'package:onboard/screens/chat_screen.dart';
import 'package:onboard/screens/comunity_screen.dart';
import 'package:onboard/screens/home_screen.dart';
import 'package:onboard/screens/profile_screen.dart';
import 'package:onboard/screens/project_screen.dart';

class MainLayoutNavbar extends StatefulWidget {
  const MainLayoutNavbar({super.key});

  @override
  State<MainLayoutNavbar> createState() => _MainLayoutNavbarState();
}

class _MainLayoutNavbarState extends State<MainLayoutNavbar> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    ProjectScreen(),
    ComunityScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 222, 233, 247),
              Colors.white,
              Color(0xff7E9FCA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: pages[currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },

              elevation: 0,

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 30),

                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_center, size: 30),
                  label: "Projects",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_outlined, size: 30),
                  label: "Community",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline, size: 30),
                  label: "Chat",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 30),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),

      // bottomNavigationBar: Container(
      //   height: 80,
      //   decoration: BoxDecoration(
      //     color: Color(0xff7E9FCA),
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(24),
      //       topRight: Radius.circular(24),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black12,
      //         blurRadius: 10,
      //         offset: Offset(0, 0),
      //       ),
      //     ],
      //   ),
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(24),
      //       topRight: Radius.circular(24),
      //     ),
      //     child: Padding(
      //       padding: const EdgeInsets.only(bottom: 8.0),
      //       child: BottomNavigationBar(
      //         currentIndex: currentIndex,

      //         onTap: (index) {
      //           setState(() {
      //             currentIndex = index;
      //           });
      //         },
      //         items: const [
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.home_outlined, size: 30),
      //             label: "Home",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.work_outline, size: 30),
      //             label: "Projects",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.people_outline_outlined, size: 30),
      //             label: "Community",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.chat_bubble_outline_sharp, size: 30),
      //             label: "Chat",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.person_outline),
      //             label: "Profile",
      //           ),
      //         ],
      //       ),
    );
  }
}
