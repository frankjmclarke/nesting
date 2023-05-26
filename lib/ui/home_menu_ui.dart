import 'package:flutter/material.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:get/get.dart';
import 'components/avatar.dart';
import 'components/form_vertical_spacing.dart';

class HomeMenuUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      builder: (controller) {
        if (controller.firestoreUser.value == null || controller.firestoreUser.value!.uid == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 120),
                  Avatar(controller.firestoreUser.value!),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FormVerticalSpace(),
                      Text(
                        'home.uidLabel'.tr +
                            ': ' +
                            controller.firestoreUser.value!.uid,
                        style: TextStyle(fontSize: 16),
                      ),
                      FormVerticalSpace(),
                      Text(
                        'home.nameLabel'.tr +
                            ': ' +
                            controller.firestoreUser.value!.name,
                        style: TextStyle(fontSize: 16),
                      ),
                      FormVerticalSpace(),
                      Text(
                        'home.emailLabel'.tr +
                            ': ' +
                            controller.firestoreUser.value!.email,
                        style: TextStyle(fontSize: 16),
                      ),
                      FormVerticalSpace(),
                      Text(
                        'home.adminUserLabel'.tr +
                            ': ' +
                            controller.admin.value.toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}