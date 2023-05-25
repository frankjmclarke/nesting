import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
//import 'package:firebase_analytics/observer.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/constants/constants.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  await GetStorage.init();
  Get.put<AuthController>(AuthController());//registers an instance of the AuthController class as a dependency, making it available for other parts of the application to use.
  Get.put<ThemeController>(ThemeController());
  Get.put<LanguageController>(LanguageController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeController.to.getThemeModeFromStore();
    return GetBuilder<LanguageController>(//The GetBuilder widget rebuilds its child whenever the state of the LanguageController changes.
      builder: (languageController) => Loading(// takes the languageController as a parameter and returns a Loading widget.
        child: GetMaterialApp(
          translations: Localization(),
          locale: languageController.getLocale,//sets the app's locale based on the locale obtained from the LanguageController.
          navigatorObservers: [//allows adding observers to track navigation events.
            // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
          ],
          debugShowCheckedModeBanner: false,
          //defaultTransition: Transition.fade,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: "/",
          getPages: AppRoutes.routes,// contains mappings between routes and their respective widgets.
        ),
      ),
    );
  }
}