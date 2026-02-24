// lib/widgets/task_details/comment_section.dart
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String taskId;
  const CommentSection({super.key, required this.taskId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    // TODO: Load from API
    setState(() {
      _comments.addAll([
        {'user': 'Ahmed', 'time': '2h ago', 'text': 'Great work! Keep it up.'},
      ]);
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = {
      'user': 'Me', // مؤقتاً
      'time': 'Just now',
      'text': _commentController.text.trim(),
      'taskId': widget.taskId,
    };

    setState(() {
      _comments.add(newComment);
      _commentController.clear();
    });
    

    // TODO: Send to API
    print('Comment sent: ${newComment['text']}');
    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Comments List
        ..._comments.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Text(c['user'][0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(c['user'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(c['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(c['text']),
                  ],
                ),
              ),
            ],
          ),
        )),

        const SizedBox(height: 16),

        // ✅ Comment Input with Send Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD1D5DC)),
          ),
          child: Row(
            children: [
              // Text Field
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              
              // ✅ Send Button
              IconButton(
                onPressed: _addComment,
                icon: const Icon(
                  Icons.send,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}