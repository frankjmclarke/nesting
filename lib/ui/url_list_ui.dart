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
              // Access the updated UrlModelList
              UrlModelList urlList = snapshot.data!;
              return ListView.builder(
                itemCount: urlList.urls.length,
                itemBuilder: (context, index) {
                  final urls = urlList.urls;
                  if (index < urls.length) {
                    final urlModel = urls[index];
                    return ListTile(
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
