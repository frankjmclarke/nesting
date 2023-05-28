import 'package:flutter/material.dart';
import 'package:flutter_starter/controllers/category_controller.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';
import 'edit_url_ui.dart';

class UrlListUI extends StatelessWidget {
  final UrlController urlController = Get.put(UrlController());
  final CategoryController myController = Get.put(CategoryController());
   int urlsOnLoad=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List'),
      ),
      body: Obx(
            () {
          if (urlController.firestoreUrlList.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<UrlModel> urls = urlController.firestoreUrlList.value!.urls;
            urlsOnLoad=urls.length;
            _updateCategoryTotal();
            if (urls.isEmpty) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              return ListView.builder(
                itemCount: urls.length,
                itemBuilder: (context, index) {
                  final urlModel = urls[index];
                  return _buildUrlItem(urlModel);
                },
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildUrlItem(UrlModel urlModel) {
    String imageUrl = urlModel.imageUrl.isNotEmpty
        ? urlModel.imageUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg/1024px-Feral_pigeon_%28Columba_livia_domestica%29%2C_2017-05-27.jpg';

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
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    _updateCategoryTotal(); // Call myMethod()
                  },
                  child: Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        urlController.deleteUrl(urlModel);
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
                    _editUrlModel(urlModel);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _updateCategoryTotal() {
      myController.updateNumItems('07hVeZyY2PM7VK8DC5QX',urlsOnLoad);
  }
  void _editUrlModel(UrlModel urlModel) {
    Get.to(EditUrlScreen(urlModel: urlModel, urlController: urlController));
  }
}
