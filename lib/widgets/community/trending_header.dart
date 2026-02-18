// lib/widgets/community/trending_header.dart
import 'package:flutter/material.dart';

class TrendingHeader extends StatelessWidget {
  const TrendingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, top: 16, bottom: 8),
      child: const Row(
        children: [
          // 🔥 TODO: Replace with your fire icon from assets
          Text(
            '🔥',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 8),
          Text(
            'Trending Posts',
            style: TextStyle(
              color: Color(0xFF101828),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}