import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebViewScreen extends StatefulWidget {
  static const routeName = '/article-webview';

  final String url;
  final String title;

  const ArticleWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends State<ArticleWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load the article: ${error.description}';
            });
          },
        ),
      );

    _loadUrl();
  }

  void _loadUrl() {
    print("News Url" + widget.url);
    final validUrl = _ensureValidUrl(widget.url);
    if (validUrl != null) {
      _controller.loadRequest(Uri.parse(validUrl));
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid URL provided';
      });
    }
  }

  String? _ensureValidUrl(String url) {
    if (url.isEmpty) {
      return null;
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
            tooltip: 'Share',
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
            tooltip: 'More options',
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_errorMessage == null)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}