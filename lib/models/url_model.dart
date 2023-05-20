//User Model
class UrlModel {
  final String uid;
  final String email;
  final String name;
  final String url;

  UrlModel(
      {required this.uid,
      required this.email,
      required this.name,
      required this.url});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'url': url,
    };
  }

  factory UrlModel.fromMap(Map data) {
    return UrlModel(
      uid: data['uid'],
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      url: data['url'] ?? '',
    );

  }

  @override
  String getUrl() {
    return url; // Customize the string representation as per your requirements
  }
  String getEmail() {
    return email; // Customize the string representation as per your requirements
  }
  Map<String, dynamic> toJson() =>
      {"uid": uid, "email": email, "name": name, "url": url};
}

class UrlModelList {
  final List<UrlModel> urls;

  UrlModelList({required this.urls});

  factory UrlModelList.fromList(List<Map> dataList) {
    List<UrlModel> urlModels = dataList
        .map((data) => UrlModel.fromMap(data))
        .toList(growable: false);
    return UrlModelList(urls: urlModels);
  }

  List<Map<String, dynamic>> toJson() =>
      urls.map((urlModel) => urlModel.toJson()).toList();

  Map<String, dynamic> toMap() {
    return {
      'urls': urls.map((urlModel) => urlModel.toMap()).toList(),
    };
  }

  bool get isNotEmpty => urls.isNotEmpty;
  UrlModel? get first => urls.isNotEmpty ? urls[0] : null;

  void add(UrlModel urlModel) {
    urls.add(urlModel);
  }
}

