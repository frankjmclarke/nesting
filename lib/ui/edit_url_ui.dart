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
      ))
      ..loadRequest(
        Uri.parse(widget.urlModel.url),
      );
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
                TextFormField(
                  controller: _addressController,
                ),
                SizedBox(height: 16.0),
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
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    UrlModel updatedUrlModel = UrlModel(
                      uid: widget.urlModel.uid,
                      email: widget.urlModel.email,
                      name: _addressController.text.trim(),
                      url: _priceController.text.trim(),
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
                  },
                  child: Text('Save Changes'),
                ),
              ],
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
