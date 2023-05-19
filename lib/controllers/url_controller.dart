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
import '../models/url_model.dart';
//our user and authentication functions for creating, logging in and out our
// user and saving our user data.
class UrlController extends GetxController {
  static UrlController to = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<UrlModel> firebaseUrl = Rxn<UrlModel>();
  Rxn<UrlModelList> firestoreUrlList = Rxn<UrlModelList>();
  final RxBool admin = false.obs;
  
  Stream<UrlModelList> get urlList => firestoreUrlList.map(
        (urlList) => UrlModelList(urls: urlList!.urls.isNotEmpty ? urlList.urls : []),
  );



  @override
  void onReady() async {
    //run every time Url List changes
    ever(firestoreUrlList, handleUrlListChanged);

    firestoreUrlList.bindStream(urlList);

    super.onReady();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  handleUrlListChanged(_firebaseUrlList) async {
    if (_firebaseUrlList?.uid != null) {
      firestoreUrlList.bindStream(streamFirestoreUrlList());
      //await isAdmin();//don't care
    }

    if (_firebaseUrlList == null) {
      print('Send to signin');
      Get.offAll(SignInUI());
    } else {
      Get.offAll(HomeUI());
    }
  }

  // Firebase user one-time fetch
  Future<User> get getUser async => _auth.currentUser!;

  // Firebase user a realtime stream
  //Stream<User?> get user => _auth.authStateChanges();

  //Streams the firestore user from the firestore collection
  Stream<UrlModelList> streamFirestoreUrlList() {
    return _db
        .doc('/urls/${firebaseUrl.value!.uid}')
        .snapshots()
        .map((snapshot) {
      List<Map> dataList = [snapshot.data()!];
      return UrlModelList.fromList(dataList);
    });
  }


  /*/get the firestore user from the firestore collection
  Future<UrlModelList> getFirestoreUser() {
    return _db.doc('/urls/${firebaseUser.value!.uid}').get().then(
            (documentSnapshot) {
          List<Map> dataList = [documentSnapshot.data()!];
          return UrlModelList.fromList(dataList);
        });
  }*/


  //Method to handle user sign in using email and password
  signInWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      emailController.clear();
      passwordController.clear();
      hideLoadingIndicator();
    } catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.signInErrorTitle'.tr, 'auth.signInError'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  //handles updating the user when updating profile
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
        //not yet working, see this issue https://github.com/delay/flutter_starter/issues/21
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
      //List<String> errors = error.toString().split(',');
      // print("Error: " + errors[1]);
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

  //updates the firestore user in users collection
  void _updateUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('/urls/${_firebaseUser.uid}').update(user.toJson());
    update();
  }

  //create the firestore user in users collection
  void _createUserListFirestore(UrlModelList urls, User _firebaseUser) {
    List<Map<String, dynamic>> jsonData = urls.toJson();
    if (jsonData.isNotEmpty) {
      _db.doc('/urls/${_firebaseUser.uid}').set(jsonData.first);
    }
    update();
  }

  //password reset email
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
 // Future<UrlModelList> get getUrlList async => _db.uid!;
  /*check if user is an admin user
  isAdmin() async {
    await getUser.then((user) async {
      DocumentSnapshot adminRef =
          await _db.collection('admin').doc(user.uid).get();
      if (adminRef.exists) {
        admin.value = true;
      } else {
        admin.value = false;
      }
      update();
    });
  }*/

  // Sign out
  Future<void> signOut() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    return _auth.signOut();
  }
}

/*
The UrlController class extends GetxController from the GetX package, which is
a state management library for Flutter.
It includes dependencies like flutter/material.dart, flutter/services.dart,
firebase_auth, cloud_firestore, and others that are required for authentication and UI components.
The UrlController class contains various methods and properties for user authentication and user management.
It initializes Firebase authentication (FirebaseAuth) and Firestore (FirebaseFirestore) instances.
The class uses Get for dependency injection to access the instance of UrlController from anywhere in the app.
The onReady method is called when the controller is initialized and sets up the
authentication state change listener using ever and binds the firebaseUser stream to user.
The handleUrlListChanged method is responsible for handling authentication state
changes and navigating the user to the appropriate UI screens based on their authentication status.
The class provides methods for signing in with email and password
(signInWithEmailAndPassword), registering a new user with email and password
(registerWithEmailAndPassword), updating the user profile (updateUser), sending
a password reset email (sendPasswordResetEmail), and signing out (signOut).
The getUser method retrieves the currently authenticated user using Firebase authentication.
The user stream provides real-time updates of the authentication state changes.
The streamFirestoreUrlList method retrieves the user data from Firestore by
streaming the document corresponding to the authenticated user's UID.
The getFirestoreUser method retrieves the user data from Firestore as a one-time fetch.
The class also includes methods for updating the Firestore user document
(_updateUserFirestore) and creating a new user document (_createUserListFirestore).
The isAdmin method checks if the current user has admin privileges by querying the admin collection in Firestore.
The signOut method handles the sign-out process.
Overall, this code provides a foundation for managing user authentication and
user data in a Flutter app using Firebase services.
 */
