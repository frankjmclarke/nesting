import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../helpers/image.dart';
import '../helpers/string_util.dart';
import '../models/category_model.dart';
import '../models/url_model.dart';

class CategoryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rxn<CategoryModel> firebaseCategory = Rxn<CategoryModel>();
  final Rxn<CategoryModelList> firestoreCategoryList = Rxn<CategoryModelList>();

  final RxBool admin = false.obs;

  static CategoryController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchUrlList();
  }

  @override
  void onReady() async {
    super.onReady();
    fetchUrlList();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Stream<CategoryModelList> get urlList => firestoreCategoryList.map(
        (urlList) => CategoryModelList(urls: urlList?.urls ?? []),
      );

  bool containsText(String text) {
    final List<CategoryModel>? urlList = firestoreCategoryList.value?.urls;
    if (urlList != null) {
      return urlList.any((CategoryModel) => CategoryModel.getTitle() == text);
    }
    return false;
  }

  Future<void> _addTextToListIfUnique() async {

      final currentList = firestoreCategoryList.value ?? CategoryModelList(urls: []);
      final newUrlModel = CategoryModel(
        uid: StringUtil.generateRandomId(15),
        title: 'title',
        parent: '07hVeZyY2PM7VK8DC5QX',
        icon: 1,
        color:1,
        flag:1,
      );
      currentList.urls.add(newUrlModel);
      firestoreCategoryList.value = currentList;
      insertUrl(newUrlModel);
  }

  Future<void> fetchUrlListByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection('category')
          .where('category', isEqualTo: category)
          .get();
      final urls =
      snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
      firestoreCategoryList.value = CategoryModelList(urls: urls);

      _db.collection('category').snapshots().listen((snapshot) {
        final urls =
        snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
        firestoreCategoryList.value = CategoryModelList(urls: urls);
        print("Firestore collection updated");
      });

      print("fetchUrlListByCategory SUCCESS ");
    } catch (error) {
      print("Error fetching url list by category: $error");
    }
/*
    final messageRef = _db
        .collection("toplevel")
        .doc("categoryA")
        .collection("urls")
        .doc("http://google.com");

 */
  }

  Future<void> fetchUrlList() async {
    try {
      final snapshot = await _db.collection('category').get();
      final urls =
          snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
      firestoreCategoryList.value = CategoryModelList(urls: urls);

      _db.collection('category').snapshots().listen((snapshot) {
        final urls =
            snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
        firestoreCategoryList.value = CategoryModelList(urls: urls);
        print("Firestore collection updated");
      });

      print("fetchUrlList SUCCESS ");
    } catch (error) {
      print("Error fetching url list: $error");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

// Insert a test CategoryModel into Firestore
  CategoryModel testUrl = CategoryModel(
    uid: StringUtil.generateRandomId(15),
    title: 'title',
    parent: '07hVeZyY2PM7VK8DC5QX',
    icon: 1,
    color:1,
    flag:1,
  );

  Future<void> insertTestUrl() async {
    insertUrl(testUrl);
  }

  Future<void> insertUrl(CategoryModel testUrl) async {
    try {
      // Convert the CategoryModel to a JSON map
      Map<String, dynamic> jsonData = testUrl.toJson();

      // Insert the test CategoryModel into Firestore
      await _db.collection('category').doc(testUrl.uid).set(jsonData);

      print('Test URL inserted successfully');
    } catch (error) {
      print('Error inserting test URL: $error');
    }
  }

  Future<void> deleteUrl(CategoryModel CategoryModel) async {
    try {
      // Delete the CategoryModel from Firestore
      await _db.collection('category').doc(CategoryModel.uid).delete();
      print('CategoryModel deleted successfully');
    } catch (error) {
      print('Error deleting CategoryModel: $error');
    }
  }

  Future<void> updateUrl(CategoryModel updatedUrl) async {
    try {
      // Convert the updated CategoryModel to a JSON map
      final jsonData = updatedUrl.toJson();

      // Update the URL document in Firestore
      await _db.collection('category').doc(updatedUrl.uid).update(jsonData);

      print('URL updated successfully');
    } catch (error) {
      print('Error updating URL: $error');
    }
  }

  void updateUrl2(CategoryModel updatedUrlModel) async {
    final index = firestoreCategoryList.value!.urls
        .indexWhere((url) => url.uid == updatedUrlModel.uid);

    if (index != -1) {
      firestoreCategoryList.value!.urls[index] = updatedUrlModel;

      // Convert the CategoryModelList to a JSON representation
      final jsonData = firestoreCategoryList.value!.toJson();

      try {
        // Save the updated list to Firestore
        await FirebaseFirestore.instance
            .collection('category')
            .doc(StringUtil.generateRandomId(12))
            .update(jsonData as Map<Object, Object?>);

        // Refresh the UI
        firestoreCategoryList.refresh();
      } catch (error) {
        // Handle any errors that occur during the Firestore operation
        print('Error updating URL: $error');
      }
    }
  }

  bool saveChanges(CategoryModel updatedUrlModel) {
    if (updatedUrlModel.title.isEmpty) {
      // Display an error message or show a snackbar indicating missing fields
      return false;
    }
    updateUrl(updatedUrlModel);
    return true;
  }

  void saverChanges(CategoryModel updatedUrlModel) async {
    try {
      // Convert the updated CategoryModel to a JSON map
      final jsonData = updatedUrlModel.toJson();

      // Update the URL document in Firestore
      await _db.collection('category').doc(updatedUrlModel.uid).update(jsonData);

      print('URL updated successfully');
    } catch (error) {
      print('Error updating URL: $error');
    }
  }
}
