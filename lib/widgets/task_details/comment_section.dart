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
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    // TODO: استبدل بـ API call حقيقي
    // مثال: final comments = await ApiService.getComments(widget.taskId);
    setState(() {
      _comments = [];
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    // TODO: استبدل بـ API call حقيقي
    // مثال: await ApiService.addComment(widget.taskId, _commentController.text.trim());
    setState(() {
      _comments.add({
        'user': 'Me',
        'time': 'Just now',
        'text': _commentController.text.trim(),
      });
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 16),

        // ── قائمة الـ comments ──
        if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No comments yet', style: TextStyle(color: Colors.grey)),
          )
        else
          ..._comments.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      (c['user'] as String)[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(
                            c['user'],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c['time'],
                            style: const TextStyle(fontSize: 16, color: Colors. grey),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(c['text'], style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // ── Comment input (multiline) ──
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD1D5DC)),
          ),
          child: TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Add Comment button ──
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _addComment,
            icon: const Icon(Icons.send, size: 18),
            label: const Text(
              'Add Comment',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}