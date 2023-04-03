import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeDSWebView extends StatefulWidget {
  final String transactionUrl;
  final String callbackUrl;
  final void Function(String? status, String? message) on3dsDone;
  final void Function(int progress)? onProgress;
  final void Function(String url)? onPageStarted;
  final void Function(WebResourceError error)? onWebResourceError;

  const ThreeDSWebView({
    super.key,
    required this.transactionUrl,
    required this.callbackUrl,
    required this.on3dsDone,
    this.onProgress,
    this.onPageStarted,
    this.onWebResourceError,
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
    widget.onProgress?.call(progress);
  }

  void _onPageStarted(String url) {
    widget.onPageStarted?.call(url);
  }

  void _onPageFinished(String url) {
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
    widget.onWebResourceError?.call(error);
  }
}
