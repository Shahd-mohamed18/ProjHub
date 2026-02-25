// lib/screens/TasksScreen/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/widgets/tasks/task_details/attachment_item.dart';
import 'package:onboard/widgets/tasks/feedback/feedback_card.dart';

class FeedbackScreen extends StatelessWidget {
  final String taskId;
  final String taskTitle;
  final List<FeedbackModel> feedbacks;

  const FeedbackScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.feedbacks,
  });

  @override
  Widget build(BuildContext context) {
    final allAttachments = feedbacks.isNotEmpty
        ? feedbacks.first.attachments
        : <AttachmentModel>[];

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
            _buildAppBar(context),
            Expanded(
              child: feedbacks.isEmpty
                  ? const Center(
                      child: Text(
                        'No feedback yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Submitted Attachments
                          if (allAttachments.isNotEmpty) ...[
                            const Text(
                              'Submitted Attachments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...allAttachments.map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: AttachmentItem(
                                  fileName: a.name,
                                  fileType: a.type,
                                  iconBackgroundColor: const Color(0xFF2196F3),
                                  showDownloadButton: true,
                                  onDownload: () {
                                    // TODO: تنزيل الملف من → a.downloadUrl
                                    debugPrint('Download: ${a.name}');
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Feedback Cards
                          ...feedbacks.map(
                            (fb) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: FeedbackCard(feedback: fb),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.only(top: 48, left: 24, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Feedback',
            style: TextStyle(fontSize: 24, fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }
}