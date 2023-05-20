import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';

class UrlListUI extends StatelessWidget {
  final UrlController myController = Get.put(UrlController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My App'),
        ),
        body: FutureBuilder<void>(
          future: myController.onInitFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: myController.firestoreUrlList.value?.urls?.length ?? 0,
                itemBuilder: (context, index) {
                  final urls = myController.firestoreUrlList.value?.urls;
                  if (urls != null && index < urls.length) {
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

            }
          },
        ),
      ),
    );
  }
}