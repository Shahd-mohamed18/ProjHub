// lib/screens/TasksScreen/task_details_screen.dart
//
// ✅ FIXES:
//  1. After submit → student can open task again and see comments (task is
//     re-fetched from backend via getTaskById, never mutated locally)
//  2. CommentSection now loads comments on every open (getCommentsForTask
//     now hits the real endpoint instead of returning [])
//  3. Supervisor attachments visible to student (from _norm fix)
//  4. Feedback button also visible on completed tasks for student (View Feedback)
//  5. Delete task available for supervisor/assistant
//  6. ✅ Attachments now use `fileUrl` to open/download the real file

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/comments/comments_cubit.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/cubits/tasks/tasks_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/repositories/api_task_repository.dart';
import 'package:onboard/screens/TasksScreen/feedback_screen.dart';
import 'package:onboard/screens/TasksScreen/submit_task_screen.dart';
import 'package:onboard/screens/supervisorScreens/give_feedback_screen.dart';
import 'package:onboard/widgets/tasks/task_details/attachment_item.dart';
import 'package:onboard/widgets/tasks/task_details/comment_section.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;
  final TasksCubit? tasksCubit;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    this.tasksCubit,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskModel _task;
  bool _loadingFresh = true;
  // True only while a delete is in flight — lets us tell delete success
  // apart from give-feedback success (both emit SupervisorTaskSuccess).
  bool _deletePending = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _loadFreshTask();
  }

  /// Fetch fresh task from backend. Always preserves supervisorAttachments —
  /// if the fresh response has them, use them; if the backend drops them
  /// (can happen after submit), keep whatever we already had.
  Future<void> _loadFreshTask() async {
    try {
      final repo = ApiTaskRepository();
      final fresh = await repo.getTaskById(_task.id);
      if (fresh != null && mounted) {
        // Preserve supervisor attachments if fresh drops them
        final supAttach =
            (fresh.supervisorAttachments != null &&
                    fresh.supervisorAttachments!.isNotEmpty)
                ? fresh.supervisorAttachments
                : _task.supervisorAttachments;

        // Preserve student attachments if fresh drops them
        final stuAttach =
            (fresh.studentAttachments != null &&
                    fresh.studentAttachments!.isNotEmpty)
                ? fresh.studentAttachments
                : _task.studentAttachments;

        setState(() {
          _task = fresh.copyWith(
            supervisorAttachments: supAttach,
            studentAttachments: stuAttach,
          );
          _loadingFresh = false;
        });
      } else {
        if (mounted) setState(() => _loadingFresh = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingFresh = false);
    }
  }

  // ── Delete task ───────────────────────────────────────────────

  void _confirmDeleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${_task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dlg);
              _deleteTask(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context) async {
    setState(() => _deletePending = true);
    try {
      final cubit = context.read<SupervisorTaskCubit>();
      cubit.deleteTask(_task.id);
    } catch (_) {
      final ok = await ApiTaskRepository().deleteTask(_task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Task deleted' : 'Failed to delete task'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ));
        if (ok) Navigator.pop(context);
      }
    }
  }

  // ── Attachment download/open ────────────────────────────────────

  /// Backend often returns a relative path (e.g. "/uploads/abc.pdf")
  /// instead of a full URL. `launchUrl` can't open that — it needs a
  /// scheme + host. This resolves relative paths against the API base.
  static const String _apiBase = 'https://projecthubb.runasp.net';

  String _resolveUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    // Make sure there's exactly one slash between base and path.
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$_apiBase$path';
  }

  Future<void> _openAttachment(String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file URL available for this attachment')),
      );
      return;
    }

    final resolved = _resolveUrl(url);
    final uri = Uri.tryParse(resolved);
    debugPrint('[Attachment] raw="$url" resolved="$resolved"');

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file URL')),
      );
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthCubit>().state.userModel?.role;
    final isSupervisor =
        role == UserRole.supervisor || role == UserRole.assistant;
    final isStudent = role == UserRole.user;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CommentsCubit(ApiTaskRepository()),
        ),
        BlocProvider(
          create: (_) => SupervisorTaskCubit(
            ApiTaskRepository(),
            context.read<TeamsCubit>(),
          ),
        ),
      ],
      child: BlocListener<SupervisorTaskCubit, SupervisorTaskState>(
        listener: (context, state) {
          if (state is SupervisorTaskSuccess && _deletePending) {
            // Only close TaskDetailsScreen when the SUCCESS came from a
            // delete operation — not from giving feedback (which manages
            // its own navigation in GiveFeedbackScreen).
            _deletePending = false;
            Navigator.pop(context);
          } else if (state is SupervisorTaskSuccess) {
            _deletePending = false;
          } else if (state is SupervisorTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
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
                _buildAppBar(context, isSupervisor),
                if (_loadingFresh) const LinearProgressIndicator(minHeight: 2),
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

                        // ── Supervisor attachments (visible to everyone) ──
                        if ((_task.supervisorAttachments ?? []).isNotEmpty) ...[
                          _buildAttachmentsSection(
                            title: 'Task Attachments',
                            attachments: _task.supervisorAttachments!,
                            accentColor: const Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Student submission (visible to supervisor) ──
                        if (isSupervisor &&
                            (_task.studentAttachments ?? []).isNotEmpty) ...[
                          _buildAttachmentsSection(
                            title: 'Student Submission',
                            attachments: _task.studentAttachments!,
                            accentColor: const Color(0xFF00A63D),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Student: upload button (only when pending) ──
                        if (isStudent && !_task.isCompleted) ...[
                          _buildUploadButton(context),
                          const SizedBox(height: 16),
                        ],

                        // ── Student: view feedback (only when completed) ──
                        if (isStudent && _task.isCompleted) ...[
                          _buildViewFeedbackButton(context),
                          const SizedBox(height: 16),
                        ],

                        // ── Supervisor/Assistant: give feedback (completed) ──
                        if (isSupervisor && _task.isCompleted) ...[
                          _buildGiveFeedbackButton(context),
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: 16),
                        // ✅ Comments always visible (works after submit too)
                        CommentSection(taskId: _task.id),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isSupervisor) {
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
          const Expanded(
            child: Text('Task Details', style: TextStyle(fontSize: 24)),
          ),
          if (isSupervisor)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _confirmDeleteTask(context),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
            ),
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
          Text(_task.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                // For completed tasks: show who submitted it if known.
                // For pending tasks: show who assigned it (supervisor/assistant).
                _task.isCompleted &&
                        _task.submittedByName != null &&
                        _task.submittedByName!.isNotEmpty
                    ? 'Submitted by: ${_task.submittedByName}'
                    : 'From: ${_task.from.isNotEmpty ? _task.from : "Supervisor"}',
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('Due ${_task.formattedDueDate}',
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _task.isCompleted
                  ? const Color(0xFF00A63D).withOpacity(0.1)
                  : const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _task.isCompleted ? '✅ Completed' : '⏳ Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _task.isCompleted
                    ? const Color(0xFF00A63D)
                    : const Color(0xFFFF9800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final desc = _task.description;
    final hasDesc = desc != null && desc.trim().isNotEmpty;

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
            hasDesc ? desc! : 'No description provided.',
            style: TextStyle(
              color: hasDesc ? Colors.black87 : Colors.grey,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Attachments now show a download button only when a real `fileUrl`
  /// is present, and tapping it opens the file via url_launcher.
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
          (f) {
            final fileUrl = f['fileUrl'] ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AttachmentItem(
                fileName: f['name'] ?? 'file',
                fileType: f['type'] ?? 'file',
                iconBackgroundColor: accentColor,
                showDownloadButton: fileUrl.isNotEmpty,
                onDownload: () => _openAttachment(fileUrl),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Student: upload button (pending only) ─────────────────────

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
            onTap: () => _navigateToSubmit(context),
            borderRadius: BorderRadius.circular(10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text('Upload File',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSubmit(BuildContext context) {
    TasksCubit? cubit = widget.tasksCubit;
    if (cubit == null) {
      try {
        cubit = context.read<TasksCubit>();
      } catch (_) {}
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (cubit != null) {
            return BlocProvider.value(
              value: cubit!,
              child: SubmitTaskScreen(task: _task),
            );
          }
          return SubmitTaskScreen(task: _task);
        },
      ),
    ).then((_) {
      // ✅ After returning from submit screen, refresh task so isCompleted updates
      _loadFreshTask();
    });
  }

  // ── Student: view feedback (completed only) ───────────────────

  Widget _buildViewFeedbackButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 265,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeedbackScreen(
                taskId: _task.id,
                taskTitle: _task.title,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A63D),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.feedback_outlined,
              color: Colors.white, size: 18),
          label: const Text('View Feedback',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // ── Supervisor/Assistant: give feedback (completed) ───────────

  Widget _buildGiveFeedbackButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 265,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SupervisorTaskCubit>(),
                child: GiveFeedbackScreen(task: _task),
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF155DFC),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.feedback_outlined,
              color: Colors.white, size: 18),
          label: const Text('Give Feedback',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}