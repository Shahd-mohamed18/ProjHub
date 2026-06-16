// lib/screens/TasksScreen/feedback_screen.dart
//
// ✅ FIXED: Screen now fetches feedback from the API on load.
// Previously it received feedbacks: const [] and never showed anything.
// Now it calls ApiTaskRepository.getFeedbackForTask(taskId) on initState.

import 'package:flutter/material.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/repositories/api_task_repository.dart';
import 'package:onboard/widgets/tasks/task_details/attachment_item.dart';
import 'package:onboard/widgets/tasks/feedback/feedback_card.dart';

class FeedbackScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const FeedbackScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
    // ✅ Removed 'feedbacks' param — we fetch them ourselves
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _repo = ApiTaskRepository();
  List<FeedbackModel> _feedbacks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final feedbacks =
          await _repo.getFeedbackForTask(widget.taskId);
      if (mounted) {
        setState(() {
          _feedbacks = feedbacks;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load feedback: $e';
          _loading = false;
        });
      }
    }
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeedback,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_feedbacks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No feedback yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'The supervisor has not given feedback yet.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Collect all feedback attachments
    final allAttachments = _feedbacks
        .expand((fb) => fb.attachments)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadFeedback,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feedback attachments (files the supervisor sent)
            if (allAttachments.isNotEmpty) ...[
              const Text(
                'Feedback Attachments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 12),
              ...allAttachments.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AttachmentItem(
                    fileName: a.name,
                    fileType: a.type,
                    iconBackgroundColor: const Color(0xFF155DFC),
                    showDownloadButton: true,
                    onDownload: () => debugPrint('Download: ${a.name}'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Feedback messages
            const Text(
              'Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),
            ..._feedbacks.map(
              (fb) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FeedbackCard(feedback: fb),
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
          Expanded(
            child: Text(
              widget.taskTitle.isNotEmpty
                  ? widget.taskTitle
                  : 'Feedback',
              style: const TextStyle(fontSize: 22, fontFamily: 'Roboto'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}