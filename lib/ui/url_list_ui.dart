import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';

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
                        context: context,
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
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}