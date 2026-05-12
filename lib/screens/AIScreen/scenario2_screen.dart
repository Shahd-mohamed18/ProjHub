import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../core/Theme/app_theme.dart';

class Scenario2Screen extends StatefulWidget {
  final ProjHubAIService aiService;

  const Scenario2Screen({super.key, required this.aiService});

  @override
  State<Scenario2Screen> createState() => _Scenario2ScreenState();
}

class _Scenario2ScreenState extends State<Scenario2Screen> {
  final TextEditingController _ideaController = TextEditingController();
  bool _isLoading = false;
  ScenarioTwoResult? _result;
  String? _error;

  Future<void> _analyzeIdea() async {
    if (_ideaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your idea first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await widget.aiService.analyzeIdea(_ideaController.text);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.aiCardGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s your project idea?',
                      style: AppTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe your idea in detail to get AI-powered analysis and similar projects',
                      style: AppTheme.bodyText.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ideaController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'E.g., "An AI-powered mobile app that helps students find study partners based on their learning style and subjects..."',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyzeIdea,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Analyze My Idea',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (_error != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI is analyzing your idea...'),
                  Text(
                    'This may take 10-30 seconds',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          
          if (_result != null) ...[
            _buildAnalysisResult(_result!),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(ScenarioTwoResult result) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.aiCardGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.title, color: AppTheme.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refined Title',
                            style: AppTheme.caption,
                          ),
                          Text(
                            result.refinedTitle,
                            style: AppTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Description',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(result.description, style: AppTheme.bodyText),
              const SizedBox(height: 12),
              
              // Detected Tracks
              Text(
                'Detected Tracks',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.detectedTracks.map((track) {
                  return Chip(
                    label: Text(track),
                    backgroundColor: AppTheme.lightBlue,
                    labelStyle: AppTheme.bodyText,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              
              // Tech Stack
              Text(
                'Recommended Tech Stack',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.lightBlue),
                ),
                child: Column(
                  children: result.techStack.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${entry.key}:',
                              style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(child: Text(entry.value, style: AppTheme.bodyText)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              if (result.howItWorks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'How It Works',
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.howItWorks.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value, style: AppTheme.bodyText)),
                      ],
                    ),
                  );
                }),
              ],
              
              if (result.similarProjects.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Similar Projects in ProjHub',
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.similarProjects.map((project) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.lightBlue),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: project.similarityScore,
                                backgroundColor: Colors.grey[200],
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(project.similarityScore * 100).toInt()}%',
                              style: AppTheme.bodyText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        if (project.explanation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            project.explanation,
                            style: AppTheme.caption,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: project.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: AppTheme.lightBlue,
                              labelStyle: AppTheme.caption,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}