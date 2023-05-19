import 'package:flutter/material.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get.dart';

import '../controllers/url_controller.dart';

class UrlListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UrlController>(
      init: UrlController(),
      builder: (controller) => controller.firestoreUrlList.value! == null
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
                      }),
                ],
              ),
              body: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 120),
                   // Avatar(controller.firestoreUser.value!),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            'UrlList.uidLabel'.tr +
                                ': ' ,//+                                controller.firestoreUrlList.value!.uid,
                            style: TextStyle(fontSize: 16)),
                        Text(
                            'UrlList.nameLabel'.tr +
                                ': ' ,//+ controller.firestoreUrlList.value!.name,
                            style: TextStyle(fontSize: 16)),
                        Text(
                            'UrlList.emailLabel'.tr +
                                ': ' ,//+controller.firestoreUrlList.value!.email,
                            style: TextStyle(fontSize: 16)),
                        Text(
                            'UrlList.adminUserLabel'.tr +
                                ': ' +
                                controller.admin.value.toString(),
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
