import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeDSWebView extends StatefulWidget {
  final String transactionUrl;
  final String callbackUrl;
  final Function on3dsDone;

  const ThreeDSWebView({
    super.key,
    required this.transactionUrl,
    required this.callbackUrl,
    required this.on3dsDone,
  });

  @override
  State<ThreeDSWebView> createState() => _ThreeDSWebViewState();
}

class _ThreeDSWebViewState extends State<ThreeDSWebView> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();

    _controller = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams());

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: _onProgress,
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.transactionUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      ),
    );
  }

  void _onProgress(int progress) {
    debugPrint('WebView is loading (progress : $progress%)');
  }

  void _onPageStarted(String url) {
    debugPrint('Page started loading: $url');
  }

  void _onPageFinished(String url) {
    debugPrint('Page finished loading: $url');
    final redirectedTo = Uri.parse(url);
    final callbackUri = Uri.parse(widget.callbackUrl);
    final bool hasReachedFinalRedirection =
        redirectedTo.host == callbackUri.host;

    if (hasReachedFinalRedirection) {
      final queryParams = redirectedTo.queryParameters;
      String? status = queryParams['status'];
      String? message = queryParams['message'];
      widget.on3dsDone(status, message);
    }
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint('''
                Page resource error:
                  code: ${error.errorCode}
                  description: ${error.description}
                  errorType: ${error.errorType}
                  isForMainFrame: ${error.isForMainFrame}
                  ''');
  }
}
