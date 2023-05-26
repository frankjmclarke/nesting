import 'package:flutter_starter/ui/onboarding/onboarding.dart';
import 'package:get/get.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:flutter_starter/ui/auth/auth.dart';
import '../ui/home_menu_ui.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => HomeUI()),
    GetPage(name: '/home-menu', page: () => HomeMenuUI()),
    GetPage(name: '/urllist', page: () => UrlListUI()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/reset-password', page: () => ResetPasswordUI()),
    GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
    GetPage(name: '/onboarding', page: () => OnboardingUI()),
  ];
}
