// lib/widgets/tasks/announcement_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class AnnouncementCard extends StatelessWidget {
  final String supervisorName;
  final String date;
  final String message;
  final String? meetingLink;
  /// If non-null, a delete (trash) icon appears — only passed for supervisors.
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    required this.supervisorName,
    required this.date,
    required this.message,
    this.meetingLink,
    this.onDelete,
  });

  Future<void> _launchURL(String url) async {
    // Ensure the url has a scheme
    final fixed =
        url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.parse(fixed);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        supervisorName.isNotEmpty
                            ? supervisorName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C950),
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.5, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supervisorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101727),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF697282),
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button (supervisor only)
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Message ─────────────────────────────────────────────────
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF364153),
              height: 1.5,
              fontFamily: 'Arimo',
            ),
          ),

          // ── Meeting link (optional) ──────────────────────────────────
          if (meetingLink != null && meetingLink!.isNotEmpty) ...[
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Arimo',
                  color: Color(0xFF364153),
                ),
                children: [
                  const TextSpan(text: 'Meeting link: '),
                  TextSpan(
                    text: meetingLink,
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _launchURL(meetingLink!),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}