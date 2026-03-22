// lib/screens/TasksScreen/task_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/comments/comments_cubit.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/TasksScreen/submit_task_screen.dart';
import 'package:onboard/screens/supervisorScreens/give_feedback_screen.dart';
import 'package:onboard/widgets/tasks/task_details/attachment_item.dart';
import 'package:onboard/widgets/tasks/task_details/comment_section.dart';
import 'package:onboard/repositories/mock_task_repository.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthCubit>().state.userModel?.role;
    // ✅ الدكتور والأسيستنت يشوفوا نفس الـ view
    final isSupervisor = role == UserRole.supervisor || role == UserRole.assistant;

    return BlocProvider(
      create: (_) => CommentsCubit(MockTaskRepository()),
      child: Scaffold(
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskInfoCard(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 24),

                      // ✅ فايل الدكتور - يظهر للكل
                      if ((task.supervisorAttachments ?? []).isNotEmpty) ...[
                        _buildAttachmentsSection(
                          title: 'Attachment',
                          attachments: task.supervisorAttachments!,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ✅ فايل الطالب - يظهر للدكتور بس
                      if (isSupervisor && (task.studentAttachments ?? []).isNotEmpty) ...[
                        _buildAttachmentsSection(
                          title: 'Student Submission',
                          attachments: task.studentAttachments!,
                          accentColor: const Color(0xFF00A63D),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ✅ Upload button - للطالب بس ولو مش completed
                      if (!isSupervisor && !task.isCompleted) ...[
                        _buildUploadButton(context),
                        const SizedBox(height: 16),
                      ],

                      // ✅ Feedback button - للدكتور بس ولو completed
                      if (isSupervisor && task.isCompleted) ...[
                        _buildFeedbackButton(context),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 16),
                      CommentSection(taskId: task.id),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
          BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Task Details', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('From: ${task.from}',
                style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('Due ${task.formattedDueDate}',
                style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 8),
          // ✅ Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? const Color(0xFF00A63D).withOpacity(0.1)
                  : const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task.isCompleted ? '✅ Completed' : '⏳ Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: task.isCompleted ? const Color(0xFF00A63D) : const Color(0xFFFF9800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.description ?? 'No description',
            style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection({
    required String title,
    required List<Map<String, String>> attachments,
    Color accentColor = const Color(0xFF2196F3),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...attachments.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AttachmentItem(
              fileName: f['name']!,
              fileType: f['type']!,
              iconBackgroundColor: accentColor,
              showDownloadButton: true,
              onDownload: () => debugPrint('Download ${f['name']}'),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ للطالب - رفع الحل
  Widget _buildUploadButton(BuildContext context) {
    return Center(
      child: Container(
        width: 265,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SubmitTaskScreen(task: task)),
            ),
            borderRadius: BorderRadius.circular(10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text('Upload File',
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ للدكتور - إعطاء Feedback بس لو completed
  Widget _buildFeedbackButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 265,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GiveFeedbackScreen(task: task)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF155DFC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.feedback_outlined, color: Colors.white, size: 18),
          label: const Text('Give Feedback',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}