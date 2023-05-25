import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';
import 'edit_url_ui.dart';

class UrlListUI extends StatelessWidget {
  final UrlController urlController = Get.put(UrlController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Obx(
            () {
          if (urlController.firestoreUrlList.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<UrlModel> urls = urlController.firestoreUrlList.value!.urls;
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
        urlController.deleteUrl(urlModel);
      },
      child: Card(
        child: Row(
          children: [
          SizedBox(
          height: 56,
          width: 56.0, // Set the width equal to the height of the card
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.0), // Adjust the border radius as needed
              bottomLeft: Radius.circular(4.0), // Adjust the border radius as needed
            ),
            child: Image.network(
              'https://images.ctfassets.net/m8onsx4mm13s/6JEns3QGHSdqgaQ8i1EyF6/fa052ce2406881e26c0162cf04980ef5/__static.gibson.com_product-images_Epiphone_EPIKNE179_TV_Yellow_EILPTVNH1_front.jpg?h=900', // Replace with your image URL
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

  void _editUrlModel(UrlModel urlModel) {
    Get.to(EditUrlScreen(urlModel: urlModel, urlController: urlController));
  }
}
