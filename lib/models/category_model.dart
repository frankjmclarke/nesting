class CategoryModel {
  final String uid;
  final String title;
  final String parent; //linked list
  final int icon;
  final int color;
  final int flag;
  final String imageUrl; // Added imageUrl field

  CategoryModel({
    required this.uid,
    required this.title,
    required this.parent,
    required this.icon,
    required this.color,
    required this.flag,
    required this.imageUrl, // Added imageUrl parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'parent': parent,
      'icon': icon,
      'color': color,
      'flag': flag,
      'imageUrl': imageUrl, // Added imageUrl key-value pair
    };
  }

  factory CategoryModel.fromMap(Map data) {
    return CategoryModel(
      uid: data['uid'] ?? '07hVeZyY2PM7VK8DC5QX',
      title: data['title'] ?? 'Hello',
      parent: data['parent'] ?? '07hVeZyY2PM7VK8DC5QX',
      icon: data['icon'] ?? 0,
      color: data['color'] ?? 0,
      flag: data['flag'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'https://cdn.onlinewebfonts.com/svg/img_259453.png', // Added imageUrl assignment
    );
  }

  @override
  String getTitle() {
    return title ?? ''; // Customize the string representation as per your requirements
  }

  String getParent() {
    return parent ?? ''; // Customize the string representation as per your requirements
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "title": title,
    "parent": parent,
    "icon": icon,
    "color": color,
    "flag": flag,
    "imageUrl": imageUrl, // Added imageUrl key-value pair
  };
}

class CategoryModelList {
  final List<CategoryModel> categories;

  CategoryModelList({required this.categories});

  factory CategoryModelList.fromList(List<Map> dataList) {
    List<CategoryModel> urlModels = dataList
        .map((data) => CategoryModel.fromMap(data))
        .toList(growable: false);
    return CategoryModelList(categories: urlModels);
  }

  List<Map<String, dynamic>> toJson() =>
      categories.map((CategoryModel) => CategoryModel.toJson()).toList();

  Map<String, dynamic> toMap() {
    return {
      'category': categories.map((CategoryModel) => CategoryModel.toMap()).toList(),
    };
  }

  bool get isNotEmpty => categories.isNotEmpty;

  CategoryModel? get first => categories.isNotEmpty ? categories[0] : null;

  void add(CategoryModel CategoryModel) {
    categories.add(CategoryModel);
  }
}