import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/ProfileScreen/profile_screen.dart';
import 'package:onboard/screens/chatScreens/chats_screen.dart';
import 'package:onboard/screens/community/community_screen.dart';
import 'package:onboard/screens/home_screen.dart';
import 'package:onboard/screens/projectScreens/project_screen.dart';
import 'package:onboard/screens/supervisorScreens/dashboard_webview_screen.dart';
import 'package:onboard/screens/supervisorScreens/supervisor_home_screen.dart';

class MainLayoutNavbar extends StatefulWidget {
  const MainLayoutNavbar({super.key});

  @override
  State<MainLayoutNavbar> createState() => _MainLayoutNavbarState();
}

class _MainLayoutNavbarState extends State<MainLayoutNavbar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status != AuthStatus.authenticated ||
            state.userModel == null) {
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong. Please login again.'),
            ),
          );
        }

        final user = state.userModel!;
        final isSupervisor = user.role == UserRole.supervisor;

        return WillPopScope(
          onWillPop: () async {
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
              decoration: const BoxDecoration(
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
                children: [
                  _getHomeScreenForUser(user),
                  const ProjectScreen(),
                  const CommunityScreen(),
                  const ChatsScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),

            floatingActionButton: (isSupervisor && currentIndex == 0)
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DashboardWebViewScreen(
                            supervisorId: user.uid,
                            supervisorName: user.fullName,
                          ),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF155CFB),
                    icon: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: _buildBottomNavBar(),
          ),
        );
      },
    );
  }

  Widget _getHomeScreenForUser(UserModel user) {
    switch (user.role) {
      case UserRole.supervisor:
      case UserRole.assistant:
        return SupervisorHomeScreen();

      case UserRole.user:
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      child: Container(
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
            // ✅ نضيف bottom padding صغير عشان النص يبقى واضح
            // ✅ من غير padding هيكفي SafeArea
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
    );
  }
}
