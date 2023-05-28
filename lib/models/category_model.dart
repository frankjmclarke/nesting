class CategoryModel {
  final String uid;
  final String title;
  final String parent;//linked list
  final int icon;
  final int color;
  final int flag;

  CategoryModel({
    required this.uid,
    required this.title,
    required this.parent,
    required this.icon,
    required this.color,
    required this.flag,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'parent': parent,
      'icon': icon,
      'color': color,
      'flag': flag,
    };
  }

  factory CategoryModel.fromMap(Map data) {
    return CategoryModel(
      uid: data['uid'],
      title: data['title'] ?? '',
      parent: data['parent'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '',
      flag: data['flag'] ?? '',
    );
  }

  @override
  String getTitle() {
    return title; // Customize the string representation as per your requirements
  }

  String getParent() {
    return parent; // Customize the string representation as per your requirements
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "title": title,
    "parent": parent,
    "icon": icon,
    "color": color,
    "flag": flag,
  };
}

class CategoryModelList {
  final List<CategoryModel> urls;

  CategoryModelList({required this.urls});

  factory CategoryModelList.fromList(List<Map> dataList) {
    List<CategoryModel> urlModels =
    dataList.map((data) => CategoryModel.fromMap(data)).toList(growable: false);
    return CategoryModelList(urls: urlModels);
  }

  List<Map<String, dynamic>> toJson() =>
      urls.map((CategoryModel) => CategoryModel.toJson()).toList();

  Map<String, dynamic> toMap() {
    return {
      'urls': urls.map((CategoryModel) => CategoryModel.toMap()).toList(),
    };
  }

  bool get isNotEmpty => urls.isNotEmpty;

  CategoryModel? get first => urls.isNotEmpty ? urls[0] : null;

  void add(CategoryModel CategoryModel) {
    urls.add(CategoryModel);
  }
}