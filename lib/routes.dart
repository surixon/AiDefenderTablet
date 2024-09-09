import 'package:ai_defender_tablet/view/dashboard_view.dart';
import 'package:ai_defender_tablet/view/downalod_app_view.dart';
import 'package:ai_defender_tablet/view/login_view.dart';
import 'package:ai_defender_tablet/view/otp_view.dart';
import 'package:ai_defender_tablet/view/settings_view.dart';
import 'package:ai_defender_tablet/view/splash_view.dart';
import 'package:ai_defender_tablet/view/wifi_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'globals.dart';

final router = GoRouter(
  navigatorKey: Globals.navigatorKey,
  initialLocation: AppPaths.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppPaths.splash,
      name: AppPaths.splash,
      pageBuilder: (context, state) {
        return const MaterialPage(child: SplashView());
      },
    ),
    GoRoute(
      path: AppPaths.login,
      name: AppPaths.login,
      pageBuilder: (context, state) {
        return const MaterialPage(child: LoginView());
      },
    ),
    GoRoute(
      path: AppPaths.wifi,
      name: AppPaths.wifi,
      pageBuilder: (context, state) {
        Map<String, dynamic>? data = state.extra as Map<String, dynamic>?;
        return MaterialPage(
            child: WifiView(
          showBack: data?['showBack'] ?? 'false',
        ));
      },
    ),
    GoRoute(
      path: AppPaths.otp,
      name: AppPaths.otp,
      pageBuilder: (context, state) {
        Map<String, dynamic> parameters = state.extra as Map<String, dynamic>;
        return MaterialPage(
            child: OtpView(
          countryCode: parameters['countryCode'],
          phone: parameters['phone'],
          verificationId: parameters['verificationId'],
        ));
      },
    ),
    GoRoute(
      path: AppPaths.dashboard,
      name: AppPaths.dashboard,
      pageBuilder: (context, state) {
        return const MaterialPage(child: DashboardView());
      },
    ),
    GoRoute(
      path: AppPaths.download,
      name: AppPaths.download,
      pageBuilder: (context, state) {
        return const MaterialPage(child: DownloadLoadAppView());
      },
    ),
    GoRoute(
      path: AppPaths.settings,
      name: AppPaths.settings,
      pageBuilder: (context, state) {
        return const MaterialPage(child: SettingsView());
      },
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(
          state.fullPath ??
              state.error?.toString() ??
              state.name ??
              "unknown error",
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);

class AppPaths {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const wifi = '/wifi';
  static const otp = '/otp';
  static const settings = '/settings';
  static const download = '/download';
}
