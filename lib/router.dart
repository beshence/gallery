import 'package:beshence_sdk_flutter/beshence_sdk_flutter.dart';
import 'package:gallery/screens/home.dart';
import 'package:gallery/screens/welcome.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: "/welcome",
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
  redirect: (context, state) {
    final selectedAccount = Beshence.selectedAccount;
    final location = state.uri.path;

    if (selectedAccount == null) {
      if (location != '/welcome') {
        return "/welcome";
      }
    } else {
      if (location == '/welcome') {
        return "/";
      }
    }
    return null;
  },
);