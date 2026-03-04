// lib/screens/community/community_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_cubit.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/screens/community/comments_screen.dart';
import 'package:onboard/screens/community/community_profile_tab.dart';
import 'package:onboard/screens/community/create_post_screen.dart';
import 'package:onboard/widgets/community/post_card.dart';
import 'package:onboard/widgets/community/trending_header.dart';
import 'package:onboard/widgets/community/whatsonyourmind.dart';
import 'package:onboard/repositories/community_repository.dart';
import 'package:onboard/repositories/mock_community_repository.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';

class CommunityScreen extends StatelessWidget {
  final int initialTab;
  const CommunityScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    // ✅ BlocProvider هنا في الأعلى عشان كل الـ children يشوفوه
    return BlocProvider(
      create: (_) => CommunityCubit(MockCommunityRepository())..loadPosts(),
      child: _CommunityScreenBody(initialTab: initialTab),
    );
  }
}

class _CommunityScreenBody extends StatefulWidget {
  final int initialTab;
  const _CommunityScreenBody({required this.initialTab});

  @override
  State<_CommunityScreenBody> createState() => _CommunityScreenBodyState();
}

class _CommunityScreenBodyState extends State<_CommunityScreenBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTab;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePost(BuildContext context) {
    // ✅ بنجيب الـ cubit من الـ context الصح
    final cubit = context.read<CommunityCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(cubit: cubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context),
            _buildTabBar(),
            Expanded(
              child: _currentTabIndex == 0
                  ? _DiscoverTab(onCreatePost: () => _openCreatePost(context))
                  : const CommunityProfileTab(),
            ),
          ],
        ),
      ),
      // ✅ الـ FAB داخل الـ Scaffold بعد ما BlocProvider اتبنى
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePost(context),
        backgroundColor: const Color(0xFF155DFC),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.only(top: 48, left: 24, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/main');
              }
            },
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Community', style: TextStyle(fontSize: 24)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.notifications_none_outlined,
                color: Colors.grey[700], size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
                color: isSelected
                    ? const Color(0xFF155CFB)
                    : Colors.transparent,
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
}

// ✅ Discover Tab كـ widget منفصل عشان يكون نضيف
class _DiscoverTab extends StatelessWidget {
  final VoidCallback onCreatePost;
  const _DiscoverTab({required this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CommunityError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<CommunityCubit>().loadPosts(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state is CommunityLoaded) {
          // ✅ فلتر البوستات على حسب الـ visibility
          // Public فقط يظهر في الـ Discover
          final visiblePosts = state.posts
              .where((p) =>
                  p.visibility == PostVisibility.public ||
                  p.userId == state.currentUserId)
              .toList();

          return RefreshIndicator(
            onRefresh: () => context.read<CommunityCubit>().refreshPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: visiblePosts.length + 1, // +1 للـ header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      WhatsOnYourMind(onTap: onCreatePost),
                      const SizedBox(height: 16),
                      const TrendingHeader(),
                    ],
                  );
                }

                final post = visiblePosts[index - 1];
                return PostCard(
                  post: post,
                  onTap: () {},
                  onCommentTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(post: post),
                      ),
                    );
                  },
                  onLike: () =>
                      context.read<CommunityCubit>().toggleLike(post.id),
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}