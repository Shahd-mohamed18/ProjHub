import 'package:flutter/material.dart';
import 'package:onboard/screens/ProfileScreen/profile_screen.dart';
import 'package:onboard/screens/chatScreens/chats_screen.dart';
import 'package:onboard/screens/community/community_screen.dart';
import 'package:onboard/screens/home_screen.dart';

import 'package:onboard/screens/projectScreens/project_screen.dart';

class MainLayoutNavbar extends StatefulWidget {
  const MainLayoutNavbar({super.key});

  @override
  State<MainLayoutNavbar> createState() => _MainLayoutNavbarState();
}

class _MainLayoutNavbarState extends State<MainLayoutNavbar> {
  int currentIndex = 0;
  
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomeScreen(),
      const ProjectScreen(),
      const CommunityScreen(),
      const ChatsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // منع الرجوع إذا كان في الصفحة الرئيسية
        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
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
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
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
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
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
      ),
    );
  }
}