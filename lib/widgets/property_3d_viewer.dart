import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Property3DViewerCard extends StatefulWidget {
  final String? virtualTourUrl;
  final String propertyTitle;

  const Property3DViewerCard({
    super.key,
    required this.virtualTourUrl,
    required this.propertyTitle,
  });

  @override
  State<Property3DViewerCard> createState() => _Property3DViewerCardState();
}

class _Property3DViewerCardState extends State<Property3DViewerCard> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        );

      // Validate URL before loading
      if (widget.virtualTourUrl != null && widget.virtualTourUrl!.isNotEmpty) {
        final uri = Uri.tryParse(widget.virtualTourUrl!);
        if (uri != null && (uri.hasScheme)) {
          _controller.loadRequest(uri);
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Invalid URL format';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to initialize WebView: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.virtualTourUrl == null || widget.virtualTourUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.view_in_ar, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  '3D Virtual Tour',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildWebViewContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading 3D Tour...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load 3D tour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeWebView();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 