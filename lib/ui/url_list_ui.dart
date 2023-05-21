import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../models/url_model.dart';

class UrlListUI extends StatelessWidget {
  final UrlController myController = Get.put(UrlController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My App'),
        ),
        body: StreamBuilder<UrlModelList>(
          stream: myController.urlList, // Use the stream from UrlController
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              UrlModelList urlList = snapshot.data!; // Access the updated UrlModelList
              return ListView.builder(
                itemCount: urlList.urls.length,
                itemBuilder: (context, index) {
                  final urls = urlList.urls;
                  if (index < urls.length) {
                    final urlModel = urls[index];
                    return Dismissible(
                      key: Key(urlModel.uid), // Use a unique key for each item
                      background: Container(
                        color: Colors.red, // Customize the background color
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
                        // Remove the item from the list when dismissed
                        myController.deleteUrl(urlModel);
                      },
                      child: Card(
                        child: ListTile(
                          title: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              urlModel.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              urlModel.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text('Data not available'),
                    );
                  }
                },
              );
            } else {
              return ListTile(
                title: Text('No data available'),
              );
            }
          },
        ),
      ),
    );
  }
}
