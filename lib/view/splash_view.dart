import 'dart:async';

import 'package:ai_defender_tablet/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/image_constants.dart';
import '../helpers/decoration.dart';
import '../helpers/shared_pref.dart';
import '../routes.dart';
import '../widgets/image_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: ImageView(
              width: 1.sw / 2,
              path: logo,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Patent Pending',
              style: ViewDecoration.textStyleMediumUrbanist(kBlackColor, 13),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    navigateToDashboard();
  }

  void navigateToDashboard() {
    var isLoggedIn = SharedPref.prefs!.getBool(SharedPref.isLoggedIn) ?? false;

    Timer(const Duration(seconds: 2),
        () => context.go(isLoggedIn ? AppPaths.dashboard : AppPaths.wifi));
  }
}


