class CategoryModel {
  final String uid;
  late final String title;
  final String parent; //linked list
  final int icon;
  final int color;
  final int flag;
  final String imageUrl; // Added imageUrl field
  final int numItems; // Added numItems field

  CategoryModel({
    required this.uid,
    required this.title,
    required this.parent,
    required this.icon,
    required this.color,
    required this.flag,
    required this.imageUrl, // Added imageUrl parameter
    required this.numItems, // Added numItems parameter
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
      'numItems': numItems, // Added numItems key-value pair
    };
  }

  CategoryModel copyWith({
    String? uid,
    String? title,
    String? parent,
    int? icon,
    int? color,
    int? flag,
    String? imageUrl,
    int? numItems,
  }) {
    return CategoryModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      parent: parent ?? this.parent,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      flag: flag ?? this.flag,
      imageUrl: imageUrl ?? this.imageUrl,
      numItems: numItems ?? this.numItems,
    );
  }
  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      uid: data['uid'] ?? '07hVeZyY2PM7VK8DC5QX',
      title: data['title'] ?? 'Hello',
      parent: data['parent'] ?? '07hVeZyY2PM7VK8DC5QX',
      icon: data['icon'] ?? 0,
      color: data['color'] ?? 0,
      flag: data['flag'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'https://cdn.onlinewebfonts.com/svg/img_259453.png',
      numItems: data['numItems'] ?? 0,
    );
  }

  @override
  String getTitle() {
    return title ?? '';
  }

  String getParent() {
    return parent ?? '';
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "title": title,
    "parent": parent,
    "icon": icon,
    "color": color,
    "flag": flag,
    "imageUrl": imageUrl,
    "numItems": numItems,
  };
}

class CategoryModelList {
  final List<CategoryModel> categories;

  CategoryModelList({required this.categories});

  factory CategoryModelList.fromList(List<Map<String, dynamic>> dataList) {
    List<CategoryModel> urlModels = dataList
        .map((data) => CategoryModel.fromMap(data))
        .toList(growable: false);
    return CategoryModelList(categories: urlModels);
  }

  List<Map<String, dynamic>> toJson() =>
      categories.map((categoryModel) => categoryModel.toJson()).toList();

  Map<String, dynamic> toMap() {
    return {
      'category': categories.map((categoryModel) => categoryModel.toMap()).toList(),
    };
  }

  bool get isNotEmpty => categories.isNotEmpty;

  CategoryModel? get first => categories.isNotEmpty ? categories[0] : null;

  void add(CategoryModel categoryModel) {
    categories.add(categoryModel);
  }
}
