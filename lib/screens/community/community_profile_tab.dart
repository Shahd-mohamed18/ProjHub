// lib/screens/community/community_profile_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_cubit.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/screens/community/comments_screen.dart';
import 'package:onboard/widgets/community/post_card.dart';

class CommunityProfileTab extends StatelessWidget {
  const CommunityProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CommunityLoaded) {
          final myPosts = state.myPosts;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 25, top: 16, bottom: 8),
                child: Text(
                  'My Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: myPosts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<CommunityCubit>().refreshPosts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: myPosts.length,
                          itemBuilder: (context, index) {
                            final post = myPosts[index];
                            return _MyPostCard(post: post);
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        if (state is CommunityError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to share something!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ✅ Card خاص بالـ Profile - بيضيف قائمة (⋮) لكل بوست
class _MyPostCard extends StatelessWidget {
  final PostModel post;
  const _MyPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Time + Menu
          Row(
            children: [
              _avatar(post.userInitial),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(post.timeAgo,
                        style: const TextStyle(
                            color: Color(0xFF6A7282), fontSize: 12)),
                  ],
                ),
              ),
              // ✅ Visibility badge دايماً ظاهر
              _VisibilityBadge(visibility: post.visibility),
              const SizedBox(width: 4),
              // ✅ قائمة (⋮)
              _PostMenu(post: post),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          // Hashtags
          if (post.hashtags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: post.hashtags
                  .map((tag) => Text(tag,
                      style: const TextStyle(
                          color: Color(0xFF155DFC), fontSize: 12)))
                  .toList(),
            ),
          // Attachment
          if (post.attachmentName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: ShapeDecoration(
                color: const Color(0xFFF9FAFB),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 8),
                  Text(post.attachmentName!,
                      style: const TextStyle(
                          color: Color(0xFF4A5565), fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<CommunityCubit>().toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.isLiked
                          ? Colors.red
                          : const Color(0xFF6A7282),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text('${post.likes} Likes',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF4A5565))),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(post: post),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 18, color: Color(0xFF6A7282)),
                    const SizedBox(width: 6),
                    Text('${post.commentsCount} Comments',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF4A5565))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(String initial) {
    return Container(
      width: 40,
      height: 40,
      decoration: const ShapeDecoration(
        color: Color(0xFFDBEAFE),
        shape: CircleBorder(),
      ),
      child: Center(
        child: Text(initial,
            style:
                const TextStyle(color: Color(0xFF155DFC), fontSize: 14)),
      ),
    );
  }
}

// ✅ قائمة الـ (⋮) - Change Visibility + Delete
class _PostMenu extends StatelessWidget {
  final PostModel post;
  const _PostMenu({required this.post});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6A7282)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        // ── Change Visibility ──
        const PopupMenuItem(
          enabled: false,
          child: Text('Change Visibility',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600)),
        ),
        _visibilityItem(
          value: 'public',
          icon: Icons.public,
          label: 'Public',
          isSelected: post.visibility == PostVisibility.public,
        ),
        _visibilityItem(
          value: 'myTeam',
          icon: Icons.group,
          label: 'My Team',
          isSelected: post.visibility == PostVisibility.myTeam,
        ),
        _visibilityItem(
          value: 'onlyMe',
          icon: Icons.lock,
          label: 'Only Me',
          isSelected: post.visibility == PostVisibility.onlyMe,
        ),
        // ── Divider ──
        const PopupMenuDivider(),
        // ── Delete ──
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 10),
              Text('Delete Post',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
        ),
      ],
      onSelected: (value) => _onSelected(context, value),
    );
  }

  PopupMenuItem<String> _visibilityItem({
    required String value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color:
                  isSelected ? const Color(0xFF155DFC) : const Color(0xFF6A7282)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? const Color(0xFF155DFC)
                      : const Color(0xFF101828),
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal)),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check, size: 16, color: Color(0xFF155DFC)),
        ],
      ),
    );
  }

  void _onSelected(BuildContext context, String value) {
    final cubit = context.read<CommunityCubit>();

    switch (value) {
      case 'public':
        cubit.changePostVisibility(post.id, PostVisibility.public);
        break;
      case 'myTeam':
        cubit.changePostVisibility(post.id, PostVisibility.myTeam);
        break;
      case 'onlyMe':
        cubit.changePostVisibility(post.id, PostVisibility.onlyMe);
        break;
      case 'delete':
        _confirmDelete(context, cubit);
        break;
    }
  }

  void _confirmDelete(BuildContext context, CommunityCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this post? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6A7282))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deletePost(post.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ✅ Badge الـ visibility - بيظهر دايماً في الـ Profile
class _VisibilityBadge extends StatelessWidget {
  final PostVisibility visibility;
  const _VisibilityBadge({required this.visibility});

  @override
  Widget build(BuildContext context) {
    final isPublic = visibility == PostVisibility.public;
    final isOnlyMe = visibility == PostVisibility.onlyMe;

    Color color = isPublic
        ? const Color(0xFF155DFC)
        : isOnlyMe
            ? Colors.orange
            : Colors.green;

    Color bg = isPublic
        ? const Color(0xFFEFF6FF)
        : isOnlyMe
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFECFDF5);

    IconData icon = isPublic
        ? Icons.public
        : isOnlyMe
            ? Icons.lock
            : Icons.group;

    String label = isPublic
        ? 'Public'
        : isOnlyMe
            ? 'Only Me'
            : 'My Team';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}