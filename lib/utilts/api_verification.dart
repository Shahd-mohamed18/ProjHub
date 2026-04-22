// lib/utils/api_verification.dart
//
// Run this once after setting useRealApi = true to confirm the backend
// is reachable and the mapping works correctly.
//
// Usage — call from main.dart AFTER Firebase.initializeApp():
//
//   import 'package:onboard/utils/api_verification.dart';
//   await ApiVerification.run();

import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/repositories/api_community_repository.dart';

class ApiVerification {
  static Future<void> run() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 Community API Verification starting...');
    print('   Base URL : http://projecthubb.runasp.net');
    print('   useRealApi flag : $useRealApi');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (!useRealApi) {
      print('⚠️  useRealApi = false  →  mock data is active.');
      print('   Set useRealApi = true in api_community_repository.dart to test.');
      return;
    }

    final repo = ApiCommunityRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'test-user';

    // 1. GET /api/Community/posts
    try {
      final posts = await repo.getPosts();
      print('✅ GET /api/Community/posts → ${posts.length} posts returned');
      if (posts.isNotEmpty) {
        final p = posts.first;
        print('   First post id=${p.id} user=${p.userName} likes=${p.likes}');
      }
    } catch (e) {
      print('❌ GET /api/Community/posts FAILED: $e');
    }

    // 2. GET /api/Community/my-posts/{userId}
    try {
      final myPosts = await repo.getMyPosts(uid);
      print('✅ GET /api/Community/my-posts/$uid → ${myPosts.length} posts');
    } catch (e) {
      print('❌ GET /api/Community/my-posts FAILED: $e');
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Verification complete. Check logs above for ✅ / ❌');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}