import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../core/Theme/app_theme.dart';

class Scenario1Screen extends StatefulWidget {
  final ProjHubAIService aiService;

  const Scenario1Screen({super.key, required this.aiService});

  @override
  State<Scenario1Screen> createState() => _Scenario1ScreenState();
}

class _Scenario1ScreenState extends State<Scenario1Screen> {
  bool _isLoading = false;
  bool _isLoadingMeta = true;
  ScenarioOneResult? _result;
  String? _error;

  List<TeamSkill> _selectedSkills = [];
  String? _selectedDomain;
  List<String> _tracks = [];
  List<String> _levels = [];
  List<String> _domains = [];
  String? _tempTrack;
  String? _tempLevel;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  @override
  void dispose() {
    _tracks.clear();
    _levels.clear();
    _domains.clear();
    _selectedSkills.clear();
    super.dispose();
  }

  Future<void> _loadMeta() async {
    if (!mounted) return;
    
    try {
      final meta = await widget.aiService.getMeta();
      if (!mounted) return;
      
      setState(() {
        _tracks = meta["tracks"]!;
        _levels = meta["levels"]!;
        _domains = meta["domains"]!;
        _isLoadingMeta = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Failed to load options: $e";
        _isLoadingMeta = false;
      });
    }
  }

  void _addSkill() {
    if (_tempTrack != null && _tempLevel != null) {
      setState(() {
        _selectedSkills.add(
          TeamSkill(track: _tempTrack!, level: _tempLevel!),
        );
        _tempTrack = null;
        _tempLevel = null;
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _selectedSkills.removeAt(index);
    });
  }

  Future<void> _getSuggestions() async {
    if (_selectedSkills.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill')),
      );
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.aiService.suggestProjects(
        skills: _selectedSkills,
        domain: _selectedDomain,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMeta) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Tell us about your team',
                      style: AppTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Team Skills:',
                      style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._selectedSkills.asMap().entries.map((entry) {
                          int idx = entry.key;
                          TeamSkill skill = entry.value;
                          return Chip(
                            label: Text('${skill.track} (${skill.level})'),
                            onDeleted: () => _removeSkill(idx),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            backgroundColor: AppTheme.lightBlue,
                            labelStyle: AppTheme.bodyText,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: DropdownButtonFormField<String>(
                                    value: _tempTrack,
                                    hint: const Text('Select Track'),
                                    isExpanded: true,
                                    items: _tracks.map((track) {
                                      return DropdownMenuItem(
                                        value: track,
                                        child: Text(track),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _tempTrack = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: DropdownButtonFormField<String>(
                                    value: _tempLevel,
                                    hint: const Text('Select Level'),
                                    isExpanded: true,
                                    items: _levels.map((level) {
                                      return DropdownMenuItem(
                                        value: level,
                                        child: Text(level),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _tempLevel = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: (_tempTrack != null && _tempLevel != null)
                                      ? _addSkill
                                      : null,
                                  icon: Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                                  iconSize: 32,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Domain (Optional):',
                      style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDomain,
                      hint: const Text('Select Domain'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ..._domains.map((domain) {
                          return DropdownMenuItem(
                            value: domain,
                            child: Text(domain),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDomain = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _getSuggestions,
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
                                'Get Project Suggestions',
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
          
          if (_result != null) ...[
            const SizedBox(height: 16),
            Text(
              'Domain: ${_result!.domain}',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            ..._result!.suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ProjectSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              Text(
                suggestion.title,
                style: AppTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              
              Text(
                suggestion.description,
                style: AppTheme.bodyText,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Recommended Tracks:',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestion.recommendedTracks.map((track) {
                  return Chip(
                    label: Text(track),
                    backgroundColor: AppTheme.lightBlue,
                    labelStyle: AppTheme.bodyText,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Tech Stack:',
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.lightBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: suggestion.techStack.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RichText(
                        text: TextSpan(
                          style: AppTheme.bodyText,
                          children: [
                            TextSpan(
                              text: '${entry.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: entry.value),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              
              if (suggestion.howItWorks.isNotEmpty) ...[
                Text(
                  'How it works:',
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.lightBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: suggestion.howItWorks.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: AppTheme.bodyText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              if (suggestion.similarProjects.isNotEmpty) ...[
                Text(
                  'Similar Projects in ProjHub:',
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...suggestion.similarProjects.map((project) {
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
                          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
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