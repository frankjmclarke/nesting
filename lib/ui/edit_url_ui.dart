import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/url_controller.dart';
import '../helpers/canada_address.dart';
import '../helpers/maps.dart';
import '../models/url_model.dart';

class EditUrlScreen extends StatefulWidget {
  final UrlModel urlModel;
  final UrlController urlController;

  EditUrlScreen({required this.urlModel, required this.urlController});

  @override
  State<EditUrlScreen> createState() => _EditUrlScreenState();
}

class _EditUrlScreenState extends State<EditUrlScreen> {
  late final WebViewController controller;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              // loadingPercentage = 0;
            });
          },
          onPageFinished: (url) {
            setState(() {
              //  loadingPercentage = 100;
            });
            _fetchHtmlText();
          },
        ));

      // Load the URL
      final uri = Uri.parse(widget.urlModel.url);
      if (uri.scheme != null && uri.host != null) {
        controller.loadRequest(uri);
        print("!!!!!!!!!!!!!" +widget.urlModel.url);
      } else {
        throw Exception('Invalid URL');
      }
    } catch (e) {
      print('Error loading URL: $e');
      // Handle the error (e.g., show an error message)
    }
    _addressController = TextEditingController(text: widget.urlModel.address);
    _priceController = TextEditingController(text: widget.urlModel.price);
    _phoneController = TextEditingController(text: widget.urlModel.phoneNumber);
    _emailController = TextEditingController(text: widget.urlModel.email);
    _nameController = TextEditingController(text: widget.urlModel.name);
    _priceController.addListener(_onUrlChanged);
  }

  //garbage test code
  Future<void> _fetchHtmlText() async {
    try {
      final response =
      await HttpClient().getUrl(Uri.parse(widget.urlModel.url));
      final responseBody = await response.close();
      final htmlBytes = await responseBody.toList();

      final htmlText =
      String.fromCharCodes(htmlBytes.expand((byteList) => byteList));
      var lo = findLongitude(htmlText);
      var la = findLatitude(htmlText);
      print('SSSS ' + la + " LONG " + lo);
      var addr = await getAddressFromLatLng(double.parse(la), double.parse(lo));
      print("IIIII+imagIIIIIIII " + addr);
      setState(() {
        if (addr.isNotEmpty) {
          _addressController.value = _addressController.value.copyWith(
            text: addr,
            selection: TextSelection.collapsed(offset: addr.length),
          );
        }
        parseAddressSimple(htmlText);
      });
    } catch (error) {
      print('Error fetching HTML: $error');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    setState(() {
      //   controller.loadRequest(_urlController.text as Uri);
    });
  }
  List<String> canceledFields = [];

  Future<void> _saveChanges() async {
    // Validate if all fields have values
    if (_addressController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nameController.text.isEmpty) {
      // Show dialog to input values for empty fields
      if (_addressController.text.isEmpty && !canceledFields.contains('Address')) {
        await _showInputDialog(context, 'Address', _addressController);
      } else if (_priceController.text.isEmpty && !canceledFields.contains('Price')) {
        await _showInputDialog(context, 'Price', _priceController);
      } else if (_phoneController.text.isEmpty && !canceledFields.contains('Phone')) {
        await _showInputDialog(context, 'Phone', _phoneController);
      } else if (_emailController.text.isEmpty && !canceledFields.contains('Email')) {
        await _showInputDialog(context, 'Email', _emailController);
      } else if (_nameController.text.isEmpty && !canceledFields.contains('Name')) {
        await _showInputDialog(context, 'Name', _nameController);
      }
      return;
    }

    // All fields have values, save changes
    UrlModel updatedUrlModel = UrlModel(
      uid: widget.urlModel.uid,
      email: widget.urlModel.email,
      name: _addressController.text.trim(),
      url: widget.urlModel.url,
      imageUrl: widget.urlModel.imageUrl,
      address: '',
      quality: 0,
      distance: 0,
      value: 0,
      size: 0,
      note: '',
      features: '',
      phoneNumber: '',
      price: '',
    );
    if (widget.urlController.saveChanges(updatedUrlModel)) {
      Get.back();
    }
  }

  Future<void> _showInputDialog(BuildContext context, String fieldName, TextEditingController controller) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter $fieldName'),
          content: TextFormField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () {
                canceledFields.add(fieldName);
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (controller.text.isNotEmpty) {
                  _saveChanges();
                  Get.back();
                } else {
                  _showInputDialog(context, fieldName, controller);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price:'),
                    TextFormField(
                      controller: _priceController,
                    ),
                    SizedBox(height: 16.0),
                    Text('Phone:'),
                    TextFormField(
                      controller: _phoneController,
                    ),
                    SizedBox(height: 16.0),
                    Text('Email:'),
                    TextFormField(
                      controller: _emailController,
                    ),
                    Text('Name:'),
                    TextFormField(
                      controller: _nameController,
                    ),
                    Text('Address:'),
                    TextFormField(
                      controller: _addressController,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
