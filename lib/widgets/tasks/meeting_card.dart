// lib/widgets/tasks/meeting_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class MeetingCard extends StatelessWidget {
  final String doctorName;
  final String date;
  final String meetingLink;
  final String phoneNumber;
  final String pin;

  const MeetingCard({
    super.key,
    required this.doctorName,
    required this.date,
    required this.meetingLink,
    required this.phoneNumber,
    required this.pin,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 329,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info row
          Row(
            children: [
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
                        doctorName.isNotEmpty ? doctorName[0] : 'D',
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
                        border: Border.all(
                          width: 1.27,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101727),
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF697282),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Meeting info
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Arimo',
                height: 1.33,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: 'To join the video meeting,\nclick this link: ',
                ),
                TextSpan(
                  text: meetingLink,
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchURL(meetingLink),
                ),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: 'Otherwise, to join by phone, dial $phoneNumber and enter this PIN: $pin',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}