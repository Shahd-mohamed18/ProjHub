// lib/screens/supervisor/create_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:onboard/cubits/announcement/announcement_cubit.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/screens/supervisorScreens/create_post_screen.dart';
import 'package:onboard/widgets/supervisor/assign_to_section.dart';
import 'package:onboard/widgets/supervisor/task_title_field.dart';
import 'package:onboard/widgets/supervisor/description_field.dart';
import 'package:onboard/widgets/supervisor/due_date_field.dart';
import 'package:onboard/widgets/supervisor/attachment_section.dart';

class CreateTaskScreen extends StatefulWidget {
  final String supervisorId;
  final String supervisorName; // ← real name for "from" field
  final String? teamId;
  final List<TeamMember> teamMembers;
  /// Full team model — needed so the Post tab can create announcements.
  final TeamModel? team;

  const CreateTaskScreen({
    super.key,
    required this.supervisorId,
    this.supervisorName = 'Supervisor',
    this.teamId,
    this.teamMembers = const [],
    this.team,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  bool _assignToAll = true;
  late Map<String, bool> _selectedMembers;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDate;
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _selectedMembers = {for (var m in widget.teamMembers) m.id: false};
    print('📝 CreateTaskScreen init — teamId=${widget.teamId} '
        'members=${widget.teamMembers.length} '
        'supervisorId=${widget.supervisorId}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── file picker ───────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) setState(() => _selectedFiles.addAll(result.files));
  }

  void _removeFile(int index) =>
      setState(() => _selectedFiles.removeAt(index));

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── save task ─────────────────────────────────────────────────

  void _saveTask() {
    print('💾 _saveTask called');

    // ── validation ──────────────────────────────────────────────
    if (_titleController.text.trim().isEmpty) {
      _snack('Please enter task title');
      return;
    }
    if (_selectedDate == null) {
      _snack('Please select due date');
      return;
    }

    // Build assigned list
    List<String> assignedTo;
    if (_assignToAll) {
      // ✅ Fix: when "All Team Members" is selected but members list is empty
      // (backend hasn't returned them yet), we still allow saving —
      // the backend will assign to all members of the team automatically.
      assignedTo = widget.teamMembers.map((m) => m.id).toList();
      print('📋 Assigning to ALL — ${assignedTo.length} members found locally');
    } else {
      assignedTo = _selectedMembers.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      if (assignedTo.isEmpty) {
        _snack('Please select at least one member');
        return;
      }
    }

    final teamId = widget.teamId ?? '';
    print('📤 Calling createTask — title="${_titleController.text.trim()}" '
        'teamId=$teamId assignedTo=$assignedTo date=$_selectedDate');

    final attachments = _selectedFiles.map((f) {
      final name = f.name;
      final type = name.contains('.') ? name.split('.').last : 'file';
      return <String, String>{'name': name, 'type': type};
    }).toList();

    context.read<SupervisorTaskCubit>().createTask(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _selectedDate!,
          assignedTo: assignedTo,
          teamId: teamId,
          attachment:
              _selectedFiles.isNotEmpty ? _selectedFiles.first.name : null,
          supervisorAttachments: attachments,
          supervisorName: widget.supervisorName,
        );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupervisorTaskCubit, SupervisorTaskState>(
      listener: (context, state) {
        print('🎯 SupervisorTaskCubit state → $state');

        if (state is SupervisorTaskSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ Fix: just pop back — AllTasksScreen manages its own cubit
          // and will reload when it becomes visible again.
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
                  child: _buildTaskForm(),
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
            Text(
              'Assign New Task',
              style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task / Post toggle — Post pushes to the real announcement screen
        _buildTypeSelector(),
        const SizedBox(height: 24),
        AssignToSection(
          assignToAll: _assignToAll,
          onAssignToAllChanged: (v) => setState(() => _assignToAll = v),
          teamMembers: widget.teamMembers,
          selectedMembers: _selectedMembers,
          onMemberChanged: (id, v) =>
              setState(() => _selectedMembers[id] = v),
        ),
        const SizedBox(height: 24),
        TaskTitleField(controller: _titleController),
        const SizedBox(height: 24),
        DescriptionField(controller: _descController),
        const SizedBox(height: 24),
        DueDateField(selectedDate: _selectedDate, onTap: _selectDate),
        const SizedBox(height: 24),
        AttachmentSection(
          selectedFiles: _selectedFiles,
          onPickFile: _pickFile,
          onRemoveFile: _removeFile,
        ),
        const SizedBox(height: 32),
        _buildActionButtons(onSave: _saveTask),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Tab selector that navigates to CreatePostScreen when "Post" is tapped.
  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Task chip — currently selected
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF1E3A8A)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4)),
            ],
          ),
          child: const Text(
            'Task',
            style: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
          ),
        ),
        const SizedBox(width: 16),
        // Post chip — tapping navigates to the announcement screen
        GestureDetector(
          onTap: () => _navigateToPost(),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 34, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Post',
              style: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToPost() {
    final team = widget.team;
    if (team == null) {
      _snack('Team info not available');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AnnouncementCubit(),
          child: CreatePostScreen(
            supervisorId: widget.supervisorId,
            team: team,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w300),
          border: InputBorder.none,
          contentPadding: maxLines > 1
              ? const EdgeInsets.all(16)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons({required VoidCallback onSave}) {
    return BlocBuilder<SupervisorTaskCubit, SupervisorTaskState>(
      builder: (context, state) {
        final loading = state is SupervisorTaskLoading;
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
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
                  onPressed: loading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155DFC),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save',
                          style: TextStyle(
                              fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}