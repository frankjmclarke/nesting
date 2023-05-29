import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../helpers/image.dart';
import '../helpers/string_util.dart';
import '../models/url_model.dart';
import '../ui/category_pick_ui.dart';

class UrlController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rxn<UrlModel> firebaseUrl = Rxn<UrlModel>();
  final Rxn<UrlModelList> firestoreUrlList = Rxn<UrlModelList>();

  final RxBool admin = false.obs;
  StreamSubscription<String>? _textStreamSubscription;
  String _sharedText = "";
  //String categoryUid = "";

  static UrlController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    fetchUrlList();
    _textStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String text) {
      _sharedText = text;
      _newUrl();
    });
    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null) {
        _sharedText = text;
        _newUrl();
      }
    });
  }

  void _newUrl(){
    Get.to(CategoryPickUI());
    //      _addTextToListIfUnique();
  }

  @override
  void onReady() async {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Stream<UrlModelList> get urlList => firestoreUrlList.map(
        (urlList) => UrlModelList(urls: urlList?.urls ?? []),
      );

  bool containsText(String text) {
    final List<UrlModel>? urlList = firestoreUrlList.value?.urls;
    if (urlList != null) {
      return urlList.any((urlModel) => urlModel.url == text);
    }
    return false;
  }

  Future<String> _fetchHtmlText(String url) async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      final responseBody = await response.close();
      final htmlBytes = await responseBody.toList();
      final htmlText =
          String.fromCharCodes(htmlBytes.expand((byteList) => byteList));
      final imageUrl =
          await getImageUrl(htmlText); // Await the getImageUrl function call
      print("IIIIIIIIIIIII $imageUrl");
      return imageUrl;
    } catch (error) {
      print('Error fetching HTML: $error');
    }
    return '';
  }

  Future<void> addTextToListIfUnique(String uid) async {
    if (!containsText(_sharedText)) {
      String imageUrl = await _fetchHtmlText(_sharedText);
      print("AAAAAA imageUrl " + imageUrl);
      final currentList = firestoreUrlList.value ?? UrlModelList(urls: []);
      final newUrlModel = UrlModel(
        uid: uid,
        email: '',
        name: '',
        url: _sharedText,
        imageUrl: imageUrl,
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
      currentList.urls.add(newUrlModel);
      firestoreUrlList.value = currentList;
      insertUrl(newUrlModel);
    }
  }

  Future<void> fetchUrlListByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection('urls')
          .where('uid', isEqualTo: category)
          .get();
      final urls =
      snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
      firestoreUrlList.value = UrlModelList(urls: urls);

      _db.collection('urls').snapshots().listen((snapshot) {
        final urls =
        snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
        firestoreUrlList.value = UrlModelList(urls: urls);
        print("Firestore collection updated");
      });

      print("fetchUrlListByCategory SUCCESS ");
    } catch (error) {
      print("Error fetching url list by category: $error");
    }
  }

  Future<void> fetchUrlList() async {
    try {
      final snapshot = await _db.collection('urls').get();
      final urls =
          snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
      firestoreUrlList.value = UrlModelList(urls: urls);

      _db.collection('urls').snapshots().listen((snapshot) {
        final urls =
            snapshot.docs.map((doc) => UrlModel.fromMap(doc.data())).toList();
        firestoreUrlList.value = UrlModelList(urls: urls);
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

// Insert a test UrlModel into Firestore
  UrlModel testUrl = UrlModel(
    uid: StringUtil.generateRandomId(15),
    email: 'testy@testy.com',
    name: 'Testing URL',
    url: 'https://google.com',
    imageUrl:
        'https://images.ctfassets.net/m8onsx4mm13s/6JEns3QGHSdqgaQ8i1EyF6/fa052ce2406881e26c0162cf04980ef5/__static.gibson.com_product-images_Epiphone_EPIKNE179_TV_Yellow_EILPTVNH1_front.jpg?h=900',
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
    final index = firestoreUrlList.value!.urls
        .indexWhere((url) => url.uid == updatedUrlModel.uid);

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
