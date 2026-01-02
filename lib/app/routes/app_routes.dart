import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/compose_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../views/auth/login_view.dart';
import '../../views/compose/compose_view.dart';
import '../../views/email/email_view.dart';
import '../../views/inbox/inbox_view.dart';
import '../../views/profile/profile_view.dart';

class AppRoutes {
  static const login = '/login';
  static const inbox = '/inbox';
  static const email = '/email';
  static const compose = '/compose';
  static const profile = '/profile';

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: inbox,
      page: () => const InboxView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => InboxController());
      }),
    ),
    GetPage(name: email, page: () => const EmailView()),
    GetPage(
      name: compose,
      page: () => const ComposeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ComposeController());
      }),
    ),
    GetPage(name: profile, page: () => const ProfileView()),
  ];
}
