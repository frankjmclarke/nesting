import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';

class CategoryListUI extends StatelessWidget {
  final CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Obx(
            () {
          if (categoryController.firestoreCategoryList.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<CategoryModel> cats = categoryController.firestoreCategoryList.value!.categories;
            if (cats.isEmpty) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              return ListView.builder(
                itemCount: cats.length,
                itemBuilder: (context, index) {
                  final catModel = cats[index];
                  return _buildCategoryItem(catModel);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel catModel) {
    String imageUrl = catModel.imageUrl.isNotEmpty
        ? catModel.imageUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg/1024px-Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg';

    return Dismissible(
      key: Key(catModel.uid),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Item'),
              content: Text('Are you sure you want to delete this item?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        categoryController.deleteCategory(catModel);
      },
      child: Card(
        child: Row(
          children: [
            SizedBox(
              height: 96,
              width: 96.0, // Set the width equal to the height of the card
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0), // Adjust the border radius as needed
                  bottomLeft: Radius.circular(4.0), // Adjust the border radius as needed
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Crop and center the image
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  catModel.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  catModel.icon.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editCategoryModel(catModel);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCategoryModel(CategoryModel catModel) {
 //   Get.to(EditCategoryScreen(catModel: catModel, categoryController: categoryController));
  }
}
