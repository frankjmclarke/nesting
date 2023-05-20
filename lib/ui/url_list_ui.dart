import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../helpers/StringUtil.dart';
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
                    return ListTile(
                      title: Text(urls[index].toString()),
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