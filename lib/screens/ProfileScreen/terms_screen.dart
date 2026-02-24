import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // App Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Terms and Services',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last updated: October 10, 2025',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: '1. Acceptance of Terms',
                      body: 'By accessing and using ProjHub, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                    ),

                    _buildSection(
                      title: '2. Use License',
                      body: 'Permission is granted to temporarily access the materials on ProjHub for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:',
                      bullets: [
                        'Modify or copy the materials',
                        'Use the materials for any commercial purpose',
                        'Attempt to decompile or reverse engineer any software',
                        'Remove any copyright or proprietary notations',
                      ],
                    ),

                    _buildSection(
                      title: '3. User Accounts',
                      body: 'You are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password. You agree not to disclose your password to any third party.',
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String body,
    List<String>? bullets,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          if (bullets != null) ...[
            const SizedBox(height: 10),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black)),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}