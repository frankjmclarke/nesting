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

  factory UrlModel.fromMap(Map data) {
    return UrlModel(
      uid: data['uid'],
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      url: data['url'] ?? '',
    );
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

  bool get isNotEmpty => urls.isNotEmpty;
  UrlModel? get first => urls.isNotEmpty ? urls[0] : null;
}

