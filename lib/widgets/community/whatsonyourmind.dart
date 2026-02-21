// lib/widgets/community/whatsonyourmind.dart
import 'package:flutter/material.dart';

class WhatsOnYourMind extends StatelessWidget {
  final VoidCallback onTap;

  const WhatsOnYourMind({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              // 👤 TODO: Replace with current user avatar from network or assets
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF155DFC),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'U', // TODO: Replace with current user initial from auth
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "What's on your mind?",
                style: TextStyle(
                  color: Color(0xFF697282),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}