// lib/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/post_model.dart';
import 'package:onboard/screens/CommunityScreen/community_profile_tab.dart';
import 'package:onboard/screens/CommunityScreen/comments_screen.dart';
import 'package:onboard/screens/CommunityScreen/create_post_screen.dart';
import 'package:onboard/widgets/community/post_card.dart';
import 'package:onboard/widgets/community/trending_header.dart';
import 'package:onboard/widgets/community/whatsonyourmind.dart';

class CommunityScreen extends StatefulWidget {
  final int initialTab; // ✅ جديد
  const CommunityScreen({super.key, this.initialTab = 0}); // ✅ default = Discover

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentTabIndex;

  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTab; // ✅ ابدأ بالتاب اللي اتبعت
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab, // ✅ هيفتح على Profile لو initialTab = 1
    );
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _fetchPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    ).then((newPost) {
      if (newPost != null) {
        setState(() => _posts.insert(0, newPost));
      }
    });
  }

  Future<void> _fetchPosts() async {
    // TODO: استبدل بـ API call حقيقي
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _posts = PostModel.mockPosts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFF4F4F4),
              Color(0xFF7D9FCA),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context),
            _buildTabBar(),
            Expanded(
              child: _currentTabIndex == 0
                  ? _buildDiscoverTab(context)
                  : const CommunityProfileTab(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: const Color(0xFF155DFC),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 44,
            child: GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/main');
                }
              },
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
          ),
          const Positioned(
            left: 64,
            top: 44,
            child: Text(
              'Community',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      height: 51,
      color: Colors.white,
      child: Row(
        children: [
          _buildTab('Discover', 0),
          _buildTab('Profile', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.27,
                color: isSelected ? const Color(0xFF155CFB) : Colors.transparent,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF155CFB)
                    : const Color(0xFF495565),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 30),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                const SizedBox(height: 16),
                WhatsOnYourMind(onTap: _openCreatePost),
                const SizedBox(height: 16),
                const TrendingHeader(),
              ],
            );
          }

          final post = _posts[index - 1];
          return PostCard(
            post: post,
            onTap: () {},
            onCommentTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(post: post),
                ),
              );
            },
          );
        },
      ),
    );
  }
}