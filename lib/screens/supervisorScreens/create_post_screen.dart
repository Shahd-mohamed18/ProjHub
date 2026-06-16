// lib/screens/supervisor/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/announcement/announcement_cubit.dart';
import 'package:onboard/cubits/announcement/announcement_state.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/screens/supervisorScreens/create_task_screen.dart';

class CreatePostScreen extends StatefulWidget {
  final String supervisorId;
  final TeamModel team;

  const CreatePostScreen({
    super.key,
    required this.supervisorId,
    required this.team,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  bool _isSubmitting = false;

  String? _publishedMessage;
  String? _publishedMeetingLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnnouncements();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  void _loadAnnouncements() {
    final teamId = int.tryParse(widget.team.id);
    if (teamId == null) return;
    context.read<AnnouncementCubit>().loadAnnouncements(
          teamId: teamId,
          userId: widget.supervisorId,
        );
  }

  void _save() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    final teamIdInt = int.tryParse(widget.team.id);
    if (teamIdInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid team ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userModel = context.read<AuthCubit>().state.userModel;
    final supervisorId = userModel?.uid ?? widget.supervisorId;
    final supervisorName = userModel?.fullName ?? 'Supervisor';
    final meetingLink = _meetingLinkController.text.trim();

    _isSubmitting = true;
    context.read<AnnouncementCubit>().createAnnouncement(
          message: message,
          meetingLink: meetingLink.isEmpty ? null : meetingLink,
          teamId: teamIdInt,
          supervisorId: supervisorId,
          supervisorName: supervisorName,
        );
  }

  void _deleteAnnouncement() {
    final teamIdInt = int.tryParse(widget.team.id);
    if (teamIdInt == null) return;
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('This will delete the current announcement. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dlg);
              context.read<AnnouncementCubit>().deleteAnnouncements(
                    teamId: teamIdInt,
                    supervisorId: widget.supervisorId,
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnnouncementCubit, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementPosted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Posted successfully ✅'),
              backgroundColor: Colors.green,
            ),
          );
          _messageController.clear();
          _meetingLinkController.clear();
          _isSubmitting = false;
          _loadAnnouncements();
        }

        if (state is AnnouncementDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement deleted'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _publishedMessage = null;
            _publishedMeetingLink = null;
          });
        }

        if (state is AnnouncementLoaded) {
          final announcements = state.announcements;
          if (announcements.isNotEmpty) {
            final latest = announcements.last;
            setState(() {
              _publishedMessage = latest.message;
              _publishedMeetingLink = latest.meetingLink;
            });
          } else {
            setState(() {
              _publishedMessage = null;
              _publishedMeetingLink = null;
            });
          }
        }

        if (state is AnnouncementError) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AnnouncementLoading || _isSubmitting;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
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
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_publishedMessage != null)
                          _buildPublishedPostCard(),

                        const SizedBox(height: 24),

                        _buildMessageField(),
                        const SizedBox(height: 20),
                        _buildMeetingLinkField(),
                        const SizedBox(height: 32),
                        _buildActionButtons(isLoading: isLoading),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 48, right: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Add Post',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF155CFB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishedPostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A63D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📢 Current Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00A63D),
                ),
              ),
              GestureDetector(
                onTap: _deleteAnnouncement,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _publishedMessage ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          if (_publishedMeetingLink != null &&
              _publishedMeetingLink!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Meeting link: $_publishedMeetingLink',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message',
          style: TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your message to the team…',
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingLinkField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Meeting Link',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 8),
            Text(
              '(optional)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: _meetingLinkController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://meet.google.com/...',
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.videocam_outlined,
                  color: Color(0xFF2196F3)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons({required bool isLoading}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD0D5DB)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      fontSize: 16, color: Color(0xFF354152))),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF155DFC),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Publish',
                      style:
                          TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}