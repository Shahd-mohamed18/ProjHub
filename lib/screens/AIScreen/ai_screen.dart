import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/core/Theme/app_theme.dart';
import '../../services/ai_service.dart';

import 'scenario1_screen.dart';
import 'scenario2_screen.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> with SingleTickerProviderStateMixin {
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
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    try {
      final isHealthy = await _aiService.isHealthy();
      if (!mounted) return;
      if (!isHealthy) {
        setState(() => _error = "AI service is currently unavailable");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Failed to connect to AI service: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlueDark),
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
        decoration: BoxDecoration(
          gradient: AppTheme.homeBackground,
        ),
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
                              _checkHealth();
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