// lib/screens/supervisorScreens/give_feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/user_model.dart';

class GiveFeedbackScreen extends StatefulWidget {
  final TaskModel task;
  const GiveFeedbackScreen({super.key, required this.task});

  @override
  State<GiveFeedbackScreen> createState() => _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _senderLabel(BuildContext context) {
    final role = context.read<AuthCubit>().state.userModel?.role;
    return role == UserRole.assistant ? 'Assistant' : 'Supervisor';
  }

  void _submit(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feedback')),
      );
      return;
    }
    context.read<SupervisorTaskCubit>().giveFeedback(
          taskId: widget.task.id,
          message: text,
          from: _senderLabel(context),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupervisorTaskCubit, SupervisorTaskState>(
      listener: (context, state) {
        if (state is SupervisorTaskSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted! ✅'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
                Color(0xFF7D9FCA)
              ],
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTaskCard(),
                      const SizedBox(height: 16),
                      _buildFeedbackInput(context),
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

  Widget _buildAppBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 1))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 48),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
            const SizedBox(width: 16),
            const Text('Give Feedback', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.task.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Submitted by: ${widget.task.from}',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFeedbackInput(BuildContext context) {
    return BlocBuilder<SupervisorTaskCubit, SupervisorTaskState>(
      builder: (context, state) {
        final isLoading = state is SupervisorTaskLoading;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Feedback',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 4,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFD0D5DB)),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFD0D5DB)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF354152))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF155DFC),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Approve & Send',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}