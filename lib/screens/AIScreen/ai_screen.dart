// import 'package:flutter/material.dart';
// import '../../core/Theme/app_theme.dart';
// import '../../services/ai_service.dart';
// import 'scenario1_screen.dart';
// import 'scenario2_screen.dart';

// class AIScreen extends StatefulWidget {
//   const AIScreen({super.key});

//   @override
//   State<AIScreen> createState() => _AIScreenState();
// }

// class _AIScreenState extends State<AIScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late ProjHubAIService _aiService;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);

//     // ✅ استخدام الـ URL الجديد من صديقتك
//     _aiService = ProjHubAIService(
//       baseUrl: "https://aya3330-projhub-ai.hf.space",
//     );

//     _initializeService();
//   }

//   Future<void> _initializeService() async {
//     try {
//       // ✅ نجرب الـ health check بدل meta
//       final isHealthy = await _aiService.healthCheck();
//       if (!mounted) return;

//       if (isHealthy) {
//         setState(() {
//           _isLoading = false;
//           _error = null;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//           _error = "AI Service is not responding. Please try again later.";
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _error = "Failed to connect to AI service: $e";
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'AI Project Assistant',
//           style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlueDark),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: AppTheme.primaryBlue,
//           labelColor: AppTheme.primaryBlue,
//           unselectedLabelColor: Colors.grey,
//           tabs: const [
//             Tab(text: 'Get Ideas', icon: Icon(Icons.lightbulb_outline)),
//             Tab(text: 'Analyze Idea', icon: Icon(Icons.analytics_outlined)),
//           ],
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: AppTheme.homeBackground,
//         ),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _error != null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                         const SizedBox(height: 16),
//                         Text(_error!),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               _isLoading = true;
//                               _error = null;
//                               _initializeService();
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.primaryBlue,
//                           ),
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   )
//                 : TabBarView(
//                     controller: _tabController,
//                     children: [
//                       Scenario1Screen(aiService: _aiService),
//                       Scenario2Screen(aiService: _aiService),
//                     ],
//                   ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../core/Theme/app_theme.dart';
import '../../services/ai_service.dart';
import 'scenario1_screen.dart';
import 'scenario2_screen.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProjHubAIService _aiService;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _aiService = ProjHubAIService(
      baseUrl: "https://aya3330-projhub-ai.hf.space",
    );

    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      final isHealthy = await _aiService.healthCheck();
      if (!mounted) return;

      if (isHealthy) {
        setState(() {
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = "AI Service is not responding. Please try again later.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Failed to connect to AI service: $e";
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Project Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlueDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Get Ideas', icon: Icon(Icons.lightbulb_outline)),
            Tab(text: 'Analyze Idea', icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.homeBackground),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                          _initializeService();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  Scenario1Screen(aiService: _aiService),
                  Scenario2Screen(aiService: _aiService),
                ],
              ),
      ),
    );
  }
}
