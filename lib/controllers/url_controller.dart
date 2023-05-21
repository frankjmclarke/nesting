import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../helpers/StringUtil.dart';
import '../models/url_model.dart';

class UrlController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rxn<UrlModel> firebaseUrl = Rxn<UrlModel>();
  final Rxn<UrlModelList> firestoreUrlList = Rxn<UrlModelList>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool admin = false.obs;
  StreamSubscription<String>? _textStreamSubscription;
  String _sharedText = "";

  static UrlController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchUrlList();
    _textStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String text) {
          _sharedText = text;
          _addTextToListIfUnique();
        });
    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null) {
        _sharedText = text;
        _addTextToListIfUnique();
      }
    });
  }

  @override
  void onReady() async {
    super.onReady();
    fetchUrlList();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Stream<UrlModelList> get urlList =>
      firestoreUrlList.map(
            (urlList) => UrlModelList(urls: urlList?.urls ?? []),
      );

  bool containsText(String text) {
    final List<UrlModel>? urlList = firestoreUrlList.value?.urls;
    if (urlList != null) {
      return urlList.any((urlModel) => urlModel.url == text);
    }
    return false;
  }

  void _addTextToListIfUnique() {
    if (!containsText(_sharedText)) {
      final currentList = firestoreUrlList.value ?? UrlModelList(urls: []);
      final newUrlModel = UrlModel(
        uid: StringUtil.generateRandomId(15),
        email: '',
        name: '',
        url: _sharedText,
      );
      currentList.urls.add(newUrlModel);
      firestoreUrlList.value = currentList;
      insertUrl(newUrlModel);
    }
  }

  Future<void> fetchUrlList() async {
    try {
      final snapshot = await _db.collection('urls').get();
      final urls = snapshot.docs.map((doc) => UrlModel.fromMap(doc.data()))
          .toList();
      firestoreUrlList.value = UrlModelList(urls: urls);

      _db.collection('urls').snapshots().listen((snapshot) {
        final urls = snapshot.docs.map((doc) => UrlModel.fromMap(doc.data()))
            .toList();
        firestoreUrlList.value = UrlModelList(urls: urls);
        print("Firestore collection updated");
      });

      print("fetchUrlList SUCCESS ");
    } catch (error) {
      print("Error fetching url list: $error");
    }
  }

  Future<void> signOut() async {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    await _auth.signOut();
  }

// Insert a test UrlModel into Firestore
  UrlModel testUrl = UrlModel(
    uid: StringUtil.generateRandomId(15),
    email: 'testy@testy.com',
    name: 'Testing URL',
    url: 'https://google.com',
  );

  Future<void> insertTestUrl() async {
    insertUrl(testUrl);
  }

  Future<void> insertUrl(UrlModel testUrl) async {
    try {
      // Convert the UrlModel to a JSON map
      Map<String, dynamic> jsonData = testUrl.toJson();

      // Insert the test UrlModel into Firestore
      await _db.collection('urls').doc(testUrl.uid).set(jsonData);

      print('Test URL inserted successfully');
    } catch (error) {
      print('Error inserting test URL: $error');
    }
  }

  Future<void> deleteUrl(UrlModel urlModel) async {
    try {
      // Delete the UrlModel from Firestore
      await _db.collection('urls').doc(urlModel.uid).delete();
      print('UrlModel deleted successfully');
    } catch (error) {
      print('Error deleting UrlModel: $error');
    }
  }
  Future<void> updateUrl(UrlModel updatedUrl) async {
    try {
      // Convert the updated UrlModel to a JSON map
      final jsonData = updatedUrl.toJson();

      // Update the URL document in Firestore
      await _db.collection('urls').doc(updatedUrl.uid).update(jsonData);

      print('URL updated successfully');
    } catch (error) {
      print('Error updating URL: $error');
    }
  }
  void updateUrl2(UrlModel updatedUrlModel) async {
    final index = firestoreUrlList.value!.urls.indexWhere((url) => url.uid == updatedUrlModel.uid);

    if (index != -1) {
      firestoreUrlList.value!.urls[index] = updatedUrlModel;

      // Convert the UrlModelList to a JSON representation
      final jsonData = firestoreUrlList.value!.toJson();

      try {
        // Save the updated list to Firestore
        await FirebaseFirestore.instance
            .collection('urls')
            .doc(StringUtil.generateRandomId(12))
            .update(jsonData as Map<Object, Object?>);

        // Refresh the UI
        firestoreUrlList.refresh();
      } catch (error) {
        // Handle any errors that occur during the Firestore operation
        print('Error updating URL: $error');
      }
    }
  }
  bool saveChanges(UrlModel updatedUrlModel) {
    if (updatedUrlModel.name.isEmpty || updatedUrlModel.url.isEmpty) {
      // Display an error message or show a snackbar indicating missing fields
      return false;
    }
    updateUrl(updatedUrlModel);
    return true;
  }

  void saverChanges(UrlModel updatedUrlModel) async {
    try {
      // Convert the updated UrlModel to a JSON map
      final jsonData = updatedUrlModel.toJson();

      // Update the URL document in Firestore
      await _db.collection('urls').doc(updatedUrlModel.uid).update(jsonData);

      print('URL updated successfully');
    } catch (error) {
      print('Error updating URL: $error');
    }
  }
}
