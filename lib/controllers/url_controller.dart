import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/auth/auth.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../helpers/StringUtil.dart';
import '../models/url_model.dart';

class UrlController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rxn<UrlModel> firebaseUrl = Rxn<UrlModel>();
  static UrlController to = Get.find();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<UrlModelList> firestoreUrlList = Rxn<UrlModelList>();
  String _sharedText = "";
  // Since firestoreUrlList is a Rxn<UrlModelList> (Reactive Extension), any
  // widget that is listening to the urlList stream will be notified of the
  // change and can update the UI accordingly.

  final RxBool admin = false.obs;
  StreamSubscription<String>? _textStreamSubscription;

  Stream<UrlModelList> get urlList => firestoreUrlList.map(
        (urlList) =>
            UrlModelList(urls: urlList!.urls.isNotEmpty ? urlList.urls : []),
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
      UrlModelList currentList = firestoreUrlList.value ?? UrlModelList(urls: []);
      UrlModel newUrlModel = UrlModel(
        uid: StringUtil.generateRandomId(15),
        email: '',
        name: '',
        url: _sharedText,
      );
      currentList.urls.add(newUrlModel);
      print('currentList ' + currentList.urls.length.toString());
      firestoreUrlList.value = currentList;
      insertUrl(newUrlModel);
    }
  }

  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    fetchUrlList().then((_) {
      _textStreamSubscription =
          ReceiveSharingIntent.getTextStream().listen((String text) {
            _sharedText = text;
            _addTextToListIfUnique();
          });
      //Receive text data when app is closed
      ReceiveSharingIntent.getInitialText().then((String? text) {
        if (text != null) {
          _sharedText = text;
          _addTextToListIfUnique();
        }
      });
      // Complete the future when fetchUrlList() finishes
      _completer
          .complete(); //manually complete the future associated with _completer.
    });
  }

  Completer<void> _completer = Completer<void>();

// By calling onInitFuture(), you can wait for the completion of the tasks
// performed in onInit() using the returned future.
  Future<void> onInitFuture() {
    return _completer.future;
  }

  Future<void> fetchUrlList() async {
    final snapshot = await _db.collection('urls').get();
    final urls =
        snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
    firestoreUrlList.value = UrlModelList(urls: urls);
    print("fetchUrlList SUCCESS ");
  }

  @override
  void onReady() async {
    // Run every time Url List changes
    // ever(firestoreUrlList, handleUrlListChanged);

    //firestoreUrlList.bindStream(urlList);
    //insertTestUrl();
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

  void handleUrlListChanged(UrlModelList? _firebaseUrlList) async {
    if (_firebaseUrlList != null) {
      firestoreUrlList
          .bindStream(streamFirestoreUrlList() as Stream<UrlModelList?>);
      //await isAdmin();
    }

    if (_firebaseUrlList == null) {
      print('Send to signin');
      Get.offAll(SignInUI());
    } else {
      Get.offAll(UrlListUI());
    }
  }

  Stream<UrlModelList> streamFirestoreUrlList() {
    return _db
        .doc('/urls/${firebaseUrl.value!.uid}')
        .snapshots()
        .map((snapshot) {
      List<Map> dataList = [snapshot.data()!];
      return UrlModelList.fromList(dataList);
    });
  }

  Future<void> updateUser(BuildContext context, UserModel user, String oldEmail,
      String password) async {
    String _authUpdateUserNoticeTitle = 'auth.updateUserSuccessNoticeTitle'.tr;
    String _authUpdateUserNotice = 'auth.updateUserSuccessNotice'.tr;
    try {
      showLoadingIndicator();
      try {
        await _auth
            .signInWithEmailAndPassword(email: oldEmail, password: password)
            .then((_firebaseUser) async {
          await _firebaseUser.user!
              .updateEmail(user.email)
              .then((value) => _updateUserFirestore(user, _firebaseUser.user!));
        });
      } catch (err) {
        print('Caught error: $err');
        // not yet working, see this issue https://github.com/delay/flutter_starter/issues/21
        if (err.toString() ==
            "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
          _authUpdateUserNoticeTitle = 'auth.updateUserEmailInUse'.tr;
          _authUpdateUserNotice = 'auth.updateUserEmailInUse'.tr;
        } else {
          _authUpdateUserNoticeTitle = 'auth.wrongPasswordNotice'.tr;
          _authUpdateUserNotice = 'auth.wrongPasswordNotice'.tr;
        }
      }
      hideLoadingIndicator();
      Get.snackbar(_authUpdateUserNoticeTitle, _authUpdateUserNotice,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on PlatformException catch (error) {
      hideLoadingIndicator();
      print(error.code);
      String authError;
      switch (error.code) {
        case 'ERROR_WRONG_PASSWORD':
          authError = 'auth.wrongPasswordNotice'.tr;
          break;
        default:
          authError = 'auth.unknownError'.tr;
          break;
      }
      Get.snackbar('auth.wrongPasswordNoticeTitle'.tr, authError,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  void _updateUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/urls/${_firebaseUser.uid}').update(user.toJson());
    update();
  }

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      hideLoadingIndicator();
      Get.snackbar(
          'auth.resetPasswordNoticeTitle'.tr, 'auth.resetPasswordNotice'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.resetPasswordFailed'.tr, error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  Future<void> signOut() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    return _auth.signOut();
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

  Future<void> insertUrl( UrlModel testUrl) async {
    try {
      // Create a new test UrlModel
      // Convert the UrlModel to a JSON map
      Map<String, dynamic> jsonData = testUrl.toJson();

      // Insert the test UrlModel into Firestore
      await _db.collection('urls').doc(testUrl.uid).set(jsonData);

      print('Test URL inserted successfully');
    } catch (error) {
      print('Error inserting test URL: $error');
    }
  }
}
