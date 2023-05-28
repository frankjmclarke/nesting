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
            final List<CategoryModel> urls = categoryController.firestoreCategoryList.value!.urls;
            if (urls.isEmpty) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              return ListView.builder(
                itemCount: urls.length,
                itemBuilder: (context, index) {
                  final urlModel = urls[index];
                  return _buildCategoryItem(urlModel);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel urlModel) {

    return Dismissible(
      key: Key(urlModel.uid),
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
        categoryController.deleteCategory(urlModel);
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
                  imageCategory,
                  fit: BoxFit.cover, // Crop and center the image
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  urlModel.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  urlModel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editCategoryModel(urlModel);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editCategoryModel(CategoryModel urlModel) {
 //   Get.to(EditCategoryScreen(urlModel: urlModel, categoryController: categoryController));
  }
}
