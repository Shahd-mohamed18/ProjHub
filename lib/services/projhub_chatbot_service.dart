// lib/services/projhub_chatbot_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// ──────────────────────────────────────────────
// SYSTEM PROMPT — شخصية الـ Chatbot
// ──────────────────────────────────────────────

const String _systemPrompt = """
You are ProjHub AI Assistant — an intelligent helper built into the ProjHub platform.

## About ProjHub
ProjHub is a collaborative academic platform that connects students, supervisors, and assistants in one unified ecosystem. It enables project sharing, task management, mentorship, and real-time collaboration — bridging the gap between academic ideas and real-world impact.

## Platform Features

### For Students:
- **Project Upload & Showcase** — Upload project with title, description, tags, category, GitHub link, cover photos, and documents
- **Project Discovery** — Search and browse all projects by category or keyword
- **Team Management** — View your team and collaborate with members
- **Task Management** — View and complete tasks assigned by your supervisor
- **Real-Time Chat** — Direct messaging with teammates and supervisors
- **Community Feed** — Post updates, share ideas, comment, like, and interact
- **Zoom Integration** — Integrated virtual meetings in the app
- **Profile** — Edit your bio, university, and profile picture
- **Notifications** — Get notified about tasks, messages, and activity

### For Supervisors (Doctors):
- All student features plus:
- **Supervisor Dashboard** — Monitor all teams and their progress
- **Team Creation** — Create teams and assign students
- **Task Assignment** — Create, assign, and track tasks with deadlines
- **Task Feedback** — Provide feedback on submitted tasks
- **Progress Monitoring** — Track team progress based on completed tasks

### For Assistants:
- All student features plus task tracking and progress reports

## How to Use Key Features

### Upload a project:
1. Go to Projects section
2. Tap the upload button
3. Fill in: Title, Description, Tags, Category, GitHub URL
4. Add cover photos and project document (PDF)
5. Submit

### Create a team (Supervisors only):
1. Go to Teams section
2. Create new team with name and project name
3. Add student members by searching their names

### Manage tasks (Supervisors):
1. Go to your team
2. Create task with title, description, deadline, assign to students
3. Students submit tasks → Supervisor gives feedback

### Use Community:
1. Go to Community Feed
2. Create posts with text and optional images
3. Comment and like on posts

### Chat:
1. Go to Chat section
2. Search for a user or open existing conversation
3. Send real-time messages

## Your Role
1. **Platform guidance** — Explain how to use any feature step by step
2. **Technical questions** — Help with programming, code review, debugging
3. **Project advice** — Help write descriptions, choose tags, structure docs
4. **General academic support** — Answer technology and programming questions

## Rules
- Always be friendly, helpful, and concise
- Respond in the SAME language the user writes in (Arabic or English)
- Give clear step-by-step instructions for platform features
- When helping with code, always explain what it does
- If unsure about a specific ProjHub detail, be honest
""";

// ──────────────────────────────────────────────
// CHAT MESSAGE MODEL
// ──────────────────────────────────────────────

class ChatMessage {
  final String role;    // 'user' or 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}

// ──────────────────────────────────────────────
// CHATBOT SERVICE
// ──────────────────────────────────────────────

class ProjHubChatbotService {
  // ⚠️ ضع الـ API Key الصحيح هنا
  static const String _apiKey = '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';
  static const String _model  = 'llama-3.3-70b-versatile';
  static const String _url    = 'https://api.groq.com/openai/v1/chat/completions';

  // الـ conversation history
  final List<ChatMessage> _history = [];

  /// إرسال رسالة والحصول على الرد
  Future<String> sendMessage(String userMessage) async {
    // أضف رسالة المستخدم للـ history
    _history.add(ChatMessage(role: 'user', content: userMessage));

    // بناء الـ messages list
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      // آخر 10 رسائل فقط عشان لا نستهلك الكثير من tokens
      ..._history.takeLast(10).map((m) => m.toJson()),
    ];

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;

        // أضف الرد للـ history
        _history.add(ChatMessage(role: 'assistant', content: reply));

        // احتفظ فقط بآخر 20 رسالة
        if (_history.length > 20) {
          _history.removeRange(0, _history.length - 20);
        }

        return reply.trim();
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        return 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.';
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return 'عذراً، حدث خطأ في الاتصال. تأكد من اتصالك بالإنترنت وحاول مرة أخرى.';
    }
  }

  /// مسح الـ history وبدء محادثة جديدة
  void clearHistory() => _history.clear();

  /// الحصول على عدد الرسائل في المحادثة
  int get messageCount => _history.length;
}

// Extension لتسهيل أخذ آخر n عناصر
extension _TakeLast<T> on List<T> {
  List<T> takeLast(int n) {
    if (n >= length) return this;
    return sublist(length - n);
  }
}