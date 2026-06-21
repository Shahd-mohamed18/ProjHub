import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DashboardWebViewScreen extends StatefulWidget {
  final String supervisorId;
  final String supervisorName;

  const DashboardWebViewScreen({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
  });

  @override
  State<DashboardWebViewScreen> createState() => _DashboardWebViewScreenState();
}

class _DashboardWebViewScreenState extends State<DashboardWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const String _dashboardBaseUrl =
      'https://projhub-dashboard-v3.vercel.app';

  @override
  void initState() {
    super.initState();

    final encodedName = Uri.encodeComponent(widget.supervisorName);
    final url =
        '$_dashboardBaseUrl/?uid=${widget.supervisorId}&name=$encodedName';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Supervisor Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF378ADD)),
            ),
        ],
      ),
    );
  }
}
