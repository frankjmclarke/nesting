import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';
import '../controllers/url_controller.dart';
import '../helpers/StringUtil.dart';
import '../models/url_model.dart';

class UrlListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UrlController>(
      init: UrlController(),
      builder: (controller) => controller.firestoreUrlList.value == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Scaffold(
        appBar: AppBar(
          title: Text('settings.title'.tr),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Get.to(SettingsUI());
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 120),
                // Avatar(controller.firestoreUser.value!),
                if (controller.firestoreUrlList.value!.urls.isEmpty)
                  Text(
                    'No links found',
                    style: TextStyle(fontSize: 16),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.firestoreUrlList.value!.urls.length,
                      itemBuilder: (context, index) {
                        UrlModel urlModel = controller.firestoreUrlList.value!.urls[index];
                        return ListTile(
                          title: Text(StringUtil.ellipsisMid(urlModel.uid.toString(), 25)),
                          subtitle: Text(StringUtil.ellipsisMid(urlModel.url.toString(), 25)),
                          // Add more widgets to display other properties of UrlModel
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
