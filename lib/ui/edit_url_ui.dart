import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';

class EditUrlScreen extends StatefulWidget {
  final UrlModel urlModel;
  final UrlController urlController;

  EditUrlScreen({required this.urlModel, required this.urlController});

  @override
  _EditUrlScreenState createState() => _EditUrlScreenState();
}

class _EditUrlScreenState extends State<EditUrlScreen> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.urlModel.name);
    _urlController = TextEditingController(text: widget.urlModel.url);
    _urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadWebView() {
    if (_webViewController != null && _urlController.text.trim().isNotEmpty) {
      _webViewController.loadUrl('about:blank').then((value) {
        Future.delayed(const Duration(milliseconds: 10), () {
          print('LOADWEBVIEW '+_urlController.text.trim());
          _webViewController.loadUrl(_urlController.text.trim());
        });
      });
    }
  }

  void _onUrlChanged() {
    setState(() {
      _loadWebView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Url'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name:'),
                TextFormField(
                  controller: _nameController,
                ),
                SizedBox(height: 16.0),
                Text('URL:'),
                TextFormField(
                  controller: _urlController,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    UrlModel updatedUrlModel = UrlModel(
                      uid: widget.urlModel.uid,
                      email: widget.urlModel.email,
                      name: _nameController.text.trim(),
                      url: _urlController.text.trim(),
                    );
                    if (widget.urlController.saveChanges(updatedUrlModel)) {
                      Get.back();
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
          Expanded(
            child: WebView(
              initialUrl: _urlController.text.trim(),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                _webViewController = controller;
                _loadWebView();
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                print('Web resource error: $error');
              },
            ),
          ),
        ],
      ),
    );
  }
}
