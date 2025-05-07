import 'dart:io';

import 'package:ai_defender_tablet/provider/loading_provider.dart';
import 'package:ai_defender_tablet/provider/theme_provider.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:ai_defender_tablet/theme/theme_color.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/dimensions_constants.dart';
import 'constants/string_constants.dart';
import 'firebase_options.dart';
import 'globals.dart';
import 'helpers/custom_scroll_behavior.dart';
import 'helpers/shared_pref.dart';
import 'locator.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDirectory = await getApplicationDocumentsDirectory();
  await configureNetworkTools(appDocDirectory.path, enableDebugging: true);

  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await EasyLocalization.ensureInitialized();
  SharedPref.prefs = await SharedPreferences.getInstance();

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);

  DartPingIOS.register();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider(mainTheme)),
      ChangeNotifierProvider(create: (context) => LoadingProvider())
    ],
    child: EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  ));

  setupLocator();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ScreenUtilInit(
        designSize: Size(
            DimensionsConstants.screenWidth, DimensionsConstants.screenHeight),
        builder: (context, child) => MaterialApp.router(
            builder: (c, widget) {
              widget = FToastBuilder()(c, widget!);
              return widget;
            },
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: themeProvider.themeData,
            routerConfig: router,
            scrollBehavior: CustomScrollBehavior(),
            scaffoldMessengerKey: Globals.scaffoldMessengerKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale));
  }
}
