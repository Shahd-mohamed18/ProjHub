// lib/screens/community_profile_tab.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/post_model.dart';
import 'package:onboard/screens/CommunityScreen/comments_screen.dart';
import 'package:onboard/widgets/community/post_card.dart';

class CommunityProfileTab extends StatefulWidget {
  const CommunityProfileTab({super.key});

  @override
  State<CommunityProfileTab> createState() => _CommunityProfileTabState();
}

class _CommunityProfileTabState extends State<CommunityProfileTab> {
  List<PostModel> _myPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyPosts();
  }

  Future<void> _fetchMyPosts() async {
    // TODO: استبدل بـ API call حقيقي
    // final posts = await PostService.getMyPosts(currentUserId);
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    setState(() {
      _myPosts = PostModel.mockPosts
          .where((post) => post.userName == 'Marwa Mohamed') // TODO: current user
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 25, top: 16, bottom: 8),
          child: Text(
            'My Posts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _myPosts.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: _fetchMyPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 30),
                        itemCount: _myPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: _myPosts[index],
                            onTap: () {
                              // TODO: Navigate to post details
                            },
                            onCommentTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommentsScreen(post: _myPosts[index]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 📝 TODO: Replace with empty posts icon from assets
          const Icon(Icons.post_add, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to create post screen
            },
            child: const Text('Create your first post'),
          ),
        ],
      ),
    );
  }
}