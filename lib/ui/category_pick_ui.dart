import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/url_list_ui.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../controllers/url_controller.dart';
import '../models/category_model.dart';

class CategoryPickUI extends StatelessWidget {
  final CategoryController categoryController = Get.put(CategoryController());
  final UrlController urlController = Get.put(UrlController());
  String categoryUid ="";
  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> cats =
        categoryController.firestoreCategoryList.value?.categories ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Category'),
      ),
      //The Obx widget wraps the ListView.builder, and it observes the categories
      //list from the CategoryController. Whenever the categories list changes,
      //the ListView.builder is automatically rebuilt with the updated data.
      body: Obx(() => ListView.builder(
        itemCount: categoryController.firestoreCategoryList.value?.categories.length,
        itemBuilder: (context, index) {
          final catModel = categoryController.firestoreCategoryList.value?.categories[index];
          return _buildCategoryItem(catModel!);
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController textController = TextEditingController();

              return AlertDialog(
                title: Text('New Category'),
                content: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      String title = textController.text;
                      insertCategoryName(title);
                     // categoryController.updateCategoryListInFirestore();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
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
                  fit: BoxFit.contain, // large as possible while still containing the source entirely within the target box.
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                onTap:  () {
                  urlController.addTextToListIfUnique(catModel.uid);
                  if (catModel.uid=='07hVeZyY2PM7VK8DC5QX')
                    catModel.uid ='';
                  categoryController.uidCurrent = catModel.uid;
                  Get.to(UrlListUI());
                },
                title: Text(
                  catModel.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  catModel.numItems.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),/*
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Get.to(UrlListUI());
                  },
                ),*/
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> insertCategoryName(String title) async {
    categoryController.insertCategoryName(title);
  }

}
