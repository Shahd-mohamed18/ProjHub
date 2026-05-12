
import 'dart:convert';
import 'package:http/http.dart' as http;


// ── Models ────────────────────────────────────────────────────────────────────

class TeamSkill {
  final String track;
  final String level;
  const TeamSkill({required this.track, required this.level});
  Map<String, dynamic> toJson() => {"track": track, "level": level};
}

class SimilarProject {
  final int id;
  final String title;
  final double similarityScore;
  final String explanation;
  final List<String> tags;

  SimilarProject({
    required this.id,
    required this.title,
    required this.similarityScore,
    required this.explanation,
    required this.tags,
  });

  factory SimilarProject.fromJson(Map<String, dynamic> j) => SimilarProject(
        id:              j["id"],
        title:           j["title"],
        similarityScore: (j["similarity_score"] as num).toDouble(),
        explanation:     j["explanation"] ?? "",
        tags:            List<String>.from(j["tags"]),
      );
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
        title:             j["title"],
        description:       j["description"],
        recommendedTracks: List<String>.from(j["recommended_tracks"]),
        techStack:         Map<String, String>.from(j["tech_stack"] ?? {}),
        howItWorks:        List<String>.from(j["how_it_works"] ?? []),
        similarProjects:   (j["similar_projects"] as List? ?? [])
                               .map((p) => SimilarProject.fromJson(p))
                               .toList(),
      );
}

class ScenarioOneResult {
  final String domain;
  final List<ProjectSuggestion> suggestions;

  ScenarioOneResult({required this.domain, required this.suggestions});

  factory ScenarioOneResult.fromJson(Map<String, dynamic> j) => ScenarioOneResult(
        domain:      j["domain"],
        suggestions: (j["suggestions"] as List)
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
        refinedTitle:    j["refined_title"],
        description:     j["description"],
        detectedTracks:  List<String>.from(j["detected_tracks"] ?? []),
        techStack:       Map<String, String>.from(j["tech_stack"] ?? {}),
        howItWorks:      List<String>.from(j["how_it_works"] ?? []),
        similarProjects: (j["similar_projects"] as List? ?? [])
                             .map((p) => SimilarProject.fromJson(p))
                             .toList(),
      );
}

class ApiMeta {
  final List<String> tracks;
  final List<String> levels;
  final List<String> domains;

  ApiMeta({required this.tracks, required this.levels, required this.domains});

  factory ApiMeta.fromJson(Map<String, dynamic> j) => ApiMeta(
        tracks:  List<String>.from(j["tracks"]),
        levels:  List<String>.from(j["levels"]),
        domains: List<String>.from(j["domains"]),
      );
}


// ── Service ───────────────────────────────────────────────────────────────────

class ProjHubAIService {
  final String baseUrl;
  final Duration timeout;

  ProjHubAIService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 60),  // AI can be slow
  });

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept":       "application/json",
  };

  // ── health check ──────────────────────────────────────────────────────────

  Future<bool> isHealthy() async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/health"), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── get valid tracks / levels / domains for dropdowns ─────────────────────

  Future<ApiMeta> getMeta() async {
    final res = await http
        .get(Uri.parse("$baseUrl/api/meta"), headers: _headers)
        .timeout(timeout);
    _checkStatus(res);
    return ApiMeta.fromJson(jsonDecode(res.body));
  }

  // ── Scenario 1: suggest projects from skills ──────────────────────────────

  Future<ScenarioOneResult> suggestProjects({
    required List<TeamSkill> skills,
    String? domain,
  }) async {
    final body = jsonEncode({
      "skills": skills.map((s) => s.toJson()).toList(),
      if (domain != null) "domain": domain,
    });

    final res = await http
        .post(Uri.parse("$baseUrl/api/suggest"), headers: _headers, body: body)
        .timeout(timeout);
    _checkStatus(res);
    return ScenarioOneResult.fromJson(jsonDecode(res.body));
  }

  // ── Scenario 2: analyze idea + find similar projects ─────────────────────

  Future<ScenarioTwoResult> analyzeIdea(String idea) async {
    final body = jsonEncode({"idea": idea});

    final res = await http
        .post(Uri.parse("$baseUrl/api/analyze"), headers: _headers, body: body)
        .timeout(timeout);
    _checkStatus(res);
    return ScenarioTwoResult.fromJson(jsonDecode(res.body));
  }

  // ── error handling ────────────────────────────────────────────────────────

  void _checkStatus(http.Response res) {
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception("API Error ${res.statusCode}: ${body['detail'] ?? res.body}");
    }
  }
}
