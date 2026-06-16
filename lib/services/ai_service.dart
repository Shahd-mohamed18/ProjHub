import 'dart:convert';
import 'package:http/http.dart' as http;

// ── Models ───────────────────────────────────────────────────────────────────

class TeamSkill {
  final String track;
  final String level;
  const TeamSkill({required this.track, required this.level});
  Map<String, dynamic> toJson() => {"track": track, "level": level};
}

class SimilarProject {
  final String id;  // ✅ changed from int to String
  final String title;
  final double similarityScore;
  final String explanation;
  final List<String> tags;
  final String? authorName;
  final String? githubUrl;

  SimilarProject({
    required this.id,
    required this.title,
    required this.similarityScore,
    required this.explanation,
    required this.tags,
    this.authorName,
    this.githubUrl,
  });

  factory SimilarProject.fromJson(Map<String, dynamic> j) {
    // ✅ Handle id as String or int
    String idValue;
    if (j["id"] is int) {
      idValue = (j["id"] as int).toString();
    } else {
      idValue = j["id"]?.toString() ?? "";
    }

    return SimilarProject(
      id: idValue,
      title: j["title"] ?? "",
      similarityScore: (j["similarity_score"] ?? 0.0).toDouble(),
      explanation: j["similarity_explanation"] ?? j["explanation"] ?? "",
      tags: j["tags"] != null
          ? (j["tags"] is String
              ? (j["tags"] as String).split(',').map((t) => t.trim()).toList()
              : List<String>.from(j["tags"]))
          : [],
      authorName: j["authorName"],
      githubUrl: j["githubUrl"],
    );
  }
}

class ProjectSuggestion {
  final String title;
  final String description;
  final List<String> recommendedTracks;
  final Map<String, String> techStack;
  final List<String> howItWorks;
  final List<SimilarProject> similarProjects;

  ProjectSuggestion({
    required this.title,
    required this.description,
    required this.recommendedTracks,
    required this.techStack,
    required this.howItWorks,
    required this.similarProjects,
  });

  factory ProjectSuggestion.fromJson(Map<String, dynamic> j) => ProjectSuggestion(
        title: j["title"] ?? "",
        description: j["description"] ?? "",
        recommendedTracks: List<String>.from(j["recommended_tracks"] ?? []),
        techStack: Map<String, String>.from(j["tech_stack"] ?? {}),
        howItWorks: List<String>.from(j["how_it_works"] ?? []),
        similarProjects: (j["similar_projects"] as List? ?? [])
            .map((p) => SimilarProject.fromJson(p))
            .toList(),
      );
}

class ScenarioOneResult {
  final String domain;
  final List<ProjectSuggestion> suggestions;

  ScenarioOneResult({required this.domain, required this.suggestions});

  factory ScenarioOneResult.fromJson(Map<String, dynamic> j) => ScenarioOneResult(
        domain: j["domain"] ?? "",
        suggestions: (j["suggestions"] as List? ?? [])
            .map((s) => ProjectSuggestion.fromJson(s))
            .toList(),
      );
}

class ScenarioTwoResult {
  final String refinedTitle;
  final String description;
  final List<String> detectedTracks;
  final Map<String, String> techStack;
  final List<String> howItWorks;
  final List<SimilarProject> similarProjects;

  ScenarioTwoResult({
    required this.refinedTitle,
    required this.description,
    required this.detectedTracks,
    required this.techStack,
    required this.howItWorks,
    required this.similarProjects,
  });

  factory ScenarioTwoResult.fromJson(Map<String, dynamic> j) => ScenarioTwoResult(
        refinedTitle: j["refined_title"] ?? "",
        description: j["description"] ?? "",
        detectedTracks: List<String>.from(j["detected_tracks"] ?? []),
        techStack: Map<String, String>.from(j["tech_stack"] ?? {}),
        howItWorks: List<String>.from(j["how_it_works"] ?? []),
        similarProjects: (j["similar_projects"] as List? ?? [])
            .map((p) => SimilarProject.fromJson(p))
            .toList(),
      );
}

// ── Service النهائي (بيتكلم مع الـ API الجديد) ─────────────────────────────────────

class ProjHubAIService {
  final String baseUrl;
  final Duration timeout;

  ProjHubAIService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 60),
  });

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  String _buildUrl(String path) {
    String cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    String cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  // ✅ Meta - مش موجود في الـ API الجديد، بنستخدم fallback data
  Future<Map<String, List<String>>> getMeta() async {
    return {
      "tracks": ["AI", "Backend", "Frontend", "Mobile", "DevOps", "Data Science", "UI/UX", "Security"],
      "levels": ["Beginner", "Intermediate", "Advanced", "Expert"],
      "domains": ["Education", "E-Commerce", "Healthcare", "Finance", "Entertainment", "Social Media", "Agriculture", "Travel"],
    };
  }

  // ✅ Scenario 1: Suggest Projects - POST /api/ai/suggest
  Future<ScenarioOneResult> suggestProjects({
    required List<TeamSkill> skills,
    String? domain,
  }) async {
    final body = jsonEncode({
      "skills": skills.map((s) => s.toJson()).toList(),
      if (domain != null && domain.isNotEmpty) "domain": domain,
    });

    final url = _buildUrl('/api/ai/suggest');
    print("📤 POST Suggest URL: $url");
    print("📤 Request body: $body");

    final res = await http
        .post(
          Uri.parse(url),
          headers: _headers,
          body: body,
        )
        .timeout(timeout);

    print("📥 Suggest response status: ${res.statusCode}");
    print("📥 Suggest response body: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("API Error ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    return ScenarioOneResult.fromJson(decoded);
  }

  // ✅ Scenario 2: Analyze Idea - POST /api/ai/analyze
  Future<ScenarioTwoResult> analyzeIdea(String idea) async {
    final body = jsonEncode({
      "idea": idea,
    });

    final url = _buildUrl('/api/ai/analyze');
    print("📤 POST Analyze URL: $url");
    print("📤 Request body: $body");

    final res = await http
        .post(
          Uri.parse(url),
          headers: _headers,
          body: body,
        )
        .timeout(timeout);

    print("📥 Analyze response status: ${res.statusCode}");
    print("📥 Analyze response body: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("API Error ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    return ScenarioTwoResult.fromJson(decoded);
  }

  // ✅ Health Check - GET /api/ai/health
  Future<bool> healthCheck() async {
    try {
      final url = _buildUrl('/api/ai/health');
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      print("⚠️ Health check failed: $e");
      return false;
    }
  }

  // ✅ Reload Projects - POST /api/ai/reload
  Future<bool> reloadProjects() async {
    try {
      final url = _buildUrl('/api/ai/reload');
      final res = await http.post(Uri.parse(url)).timeout(const Duration(seconds: 30));
      return res.statusCode == 200;
    } catch (e) {
      print("⚠️ Reload projects failed: $e");
      return false;
    }
  }
}