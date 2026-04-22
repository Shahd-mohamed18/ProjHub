// lib/screens/supervisor/create_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/widgets/supervisor/task_type_selector.dart';
import 'package:onboard/widgets/supervisor/assign_to_section.dart'; // ✅ بنستخدم الويدجت
import 'package:onboard/widgets/supervisor/task_title_field.dart';
import 'package:onboard/widgets/supervisor/description_field.dart';
import 'package:onboard/widgets/supervisor/due_date_field.dart';
import 'package:onboard/widgets/supervisor/attachment_section.dart';

class CreateTaskScreen extends StatefulWidget {
  final String supervisorId;
  final String? teamId;
  final List<TeamMember> teamMembers;

  const CreateTaskScreen({
    super.key,
    required this.supervisorId,
    this.teamId,
    this.teamMembers = const [],
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  bool _isTask = true;
  bool _assignToAll = true;
  late Map<String, bool> _selectedMembers;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescController = TextEditingController();
  DateTime? _selectedDate;
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _selectedMembers = {for (var m in widget.teamMembers) m.id: false};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _postTitleController.dispose();
    _postDescController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) setState(() => _selectedFiles.addAll(result.files));
  }

  void _removeFile(int index) => setState(() => _selectedFiles.removeAt(index));

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter task title')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select due date')));
      return;
    }
    final assignedTo = _assignToAll
        ? widget.teamMembers.map((m) => m.id).toList()
        : _selectedMembers.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
    if (assignedTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one member')));
      return;
    }
    context.read<SupervisorTaskCubit>().createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _selectedDate!,
          assignedTo: assignedTo,
          teamId: widget.teamId ?? 'team_a',
          attachment:
              _selectedFiles.isNotEmpty ? _selectedFiles.first.name : null,
        );
  }

  void _savePost() {
    if (_postTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter post title')));
      return;
    }
    if (_postDescController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter post description')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupervisorTaskCubit, SupervisorTaskState>(
      listener: (context, state) {
        if (state is SupervisorTaskSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task created successfully!')));
              Navigator.pushReplacementNamed(context, '/all_tasks');
          Navigator.pop(context);
        } else if (state is SupervisorTaskError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
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
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: _isTask ? _buildTaskForm() : _buildPostForm(),
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
          BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 1))
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
            Text(_isTask ? 'Assign New Task' : 'Add Post',
                style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskTypeSelector(
            isTask: _isTask, onChanged: (v) => setState(() => _isTask = v)),
        const SizedBox(height: 24),
        // ✅ بنستخدم AssignToSection widget مع TeamMember الجديد
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
        DescriptionField(controller: _descriptionController),
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

  Widget _buildPostForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskTypeSelector(
            isTask: _isTask, onChanged: (v) => setState(() => _isTask = v)),
        const SizedBox(height: 24),
        const Text('Post Title',
            style: TextStyle(fontSize: 20, fontFamily: 'Roboto')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
            ],
          ),
          child: TextField(
            controller: _postTitleController,
            decoration: InputDecoration(
              hintText: 'enter post title',
              hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w300),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Description',
            style: TextStyle(fontSize: 20, fontFamily: 'Roboto')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
            ],
          ),
          child: TextField(
            controller: _postDescController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'describe your post',
              hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w300),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildActionButtons(onSave: _savePost),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons({required VoidCallback onSave}) {
    return BlocBuilder<SupervisorTaskCubit, SupervisorTaskState>(
      builder: (context, state) {
        final isLoading = state is SupervisorTaskLoading;
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
                      style:
                          TextStyle(fontSize: 16, color: Color(0xFF354152))),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSave,
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
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save',
                          style:
                              TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}