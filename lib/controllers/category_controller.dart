import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/string_util.dart';
import '../models/category_model.dart';

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
    //fetchCategoryList();
  }

  @override
  void onReady() async {
    super.onReady();
    fetchCategoryList();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Stream<CategoryModelList> get CategoryList => firestoreCategoryList.map(
        (CategoryList) => CategoryModelList(categories: CategoryList?.categories ?? []),
      );

  bool containsText(String text) {
    final List<CategoryModel>? CategoryList = firestoreCategoryList.value?.categories;
    if (CategoryList != null) {
      return CategoryList.any((CategoryModel) => CategoryModel.getTitle() == text);
    }
    return false;
  }

  Future<void> _addTextToListIfUnique() async {

      final currentList = firestoreCategoryList.value ?? CategoryModelList(categories: []);
      final newCategoryModel = CategoryModel(
        uid: StringUtil.generateRandomId(15),
        title: 'title',
        parent: '07hVeZyY2PM7VK8DC5QX',
        icon: 1,
        color:1,
        flag:1,
        imageUrl: 'https://cdn.onlinewebfonts.com/svg/img_259453.png',
      );
      currentList.categories.add(newCategoryModel);
      firestoreCategoryList.value = currentList;
      insertCategory(newCategoryModel);
  }
/*
  Future<void> fetchCategoryListByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection('category')
          .where('category', isEqualTo: category)
          .get();
      final cats =
      snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
      firestoreCategoryList.value = CategoryModelList(categories: cats);

      _db.collection('category').snapshots().listen((snapshot) {
        final cats =
        snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
        firestoreCategoryList.value = CategoryModelList(categories: cats);
        print("Firestore collection updated");
      });

      print("fetchCategoryListByCategory SUCCESS ");
    } catch (error) {
      print("Error fetching Category list by category: $error");
    }
/*
    final messageRef = _db
        .collection("toplevel")
        .doc("categoryA")
        .collection("Categorys")
        .doc("http://google.com");

 */
  }
*/
  Future<void> fetchCategoryList() async {
    try {
      final snapshot = await _db.collection('category').get();
      final cats =
          snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
      firestoreCategoryList.value = CategoryModelList(categories: cats);

      _db.collection('category').snapshots().listen((snapshot) {
        final cats =
            snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
        firestoreCategoryList.value = CategoryModelList(categories: cats);
        print("Firestore fetchCategoryList");
      });

      print("fetchCategoryList SUCCESS ");
    } catch (error) {
      print("Error fetching Category list: $error");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

// Insert a test CategoryModel into Firestore
  CategoryModel testCategory = CategoryModel(
    uid: StringUtil.generateRandomId(15),
    title: 'title',
    parent: '07hVeZyY2PM7VK8DC5QX',
    icon: 1,
    color:1,
    flag:1,
    imageUrl: 'https://cdn.onlinewebfonts.com/svg/img_259453.png',
  );

  Future<void> insertTestCategory() async {
    insertCategory(testCategory);
  }

  Future<void> insertCategory(CategoryModel testCategory) async {
    try {
      // Convert the CategoryModel to a JSON map
      Map<String, dynamic> jsonData = testCategory.toJson();

      // Insert the test CategoryModel into Firestore
      await _db.collection('category').doc(testCategory.uid).set(jsonData);

      print('Test Category inserted successfully');
    } catch (error) {
      print('Error inserting test Category: $error');
    }
  }

  Future<void> deleteCategory(CategoryModel CategoryModel) async {
    try {
      // Delete the CategoryModel from Firestore
      await _db.collection('category').doc(CategoryModel.uid).delete();
      print('CategoryModel deleted successfully');
    } catch (error) {
      print('Error deleting CategoryModel: $error');
    }
  }

  Future<void> updateCategory(CategoryModel updatedCategory) async {
    try {
      // Convert the updated CategoryModel to a JSON map
      final jsonData = updatedCategory.toJson();

      // Update the Category document in Firestore
      await _db.collection('category').doc(updatedCategory.uid).update(jsonData);

      print('Category updated successfully');
    } catch (error) {
      print('Error updating Category: $error');
    }
  }
/*
  void updateCategory2(CategoryModel updatedCategoryModel) async {
    final index = firestoreCategoryList.value!.categories
        .indexWhere((Category) => Category.uid == updatedCategoryModel.uid);

    if (index != -1) {
      firestoreCategoryList.value!.categories[index] = updatedCategoryModel;

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
        print('Error updating Category: $error');
      }
    }
  }*/

  bool saveChanges(CategoryModel updatedCategoryModel) {
    if (updatedCategoryModel.title.isEmpty) {
      // Display an error message or show a snackbar indicating missing fields
      return false;
    }
    updateCategory(updatedCategoryModel);
    return true;
  }

  void saverChanges(CategoryModel updatedCategoryModel) async {
    try {
      // Convert the updated CategoryModel to a JSON map
      final jsonData = updatedCategoryModel.toJson();

      // Update the Category document in Firestore
      await _db.collection('category').doc(updatedCategoryModel.uid).update(jsonData);

      print('Category updated successfully');
    } catch (error) {
      print('Error updating Category: $error');
    }
  }
}
