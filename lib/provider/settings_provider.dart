import 'dart:ui';

import 'package:ai_defender_tablet/dialog/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../globals.dart';
import '../helpers/toast_helper.dart';
import '../helpers/shared_pref.dart';
import '../routes.dart';
import 'base_provider.dart';

class SettingsProvider extends BaseProvider {
  List<String> list = [];

  loadOptionList() {
    list = ["Location", 'Bluetooth', 'WiFi', 'Logout'];
  }

  void logout(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const CommonDialog(
                description: "Are you sure want to logout?",
              ),
            )).then((value) async {
      if (value != null && value) {
        SharedPref.prefs?.clear();
        context.go(AppPaths.login);
      }
    });
  }

  Future<void> copyIdToClipboard() async {
    await Clipboard.setData(ClipboardData(
        text: SharedPref.prefs?.getString(SharedPref.userId) ?? ''));
    ToastHelper.showMessage("Copied!");
  }
}
