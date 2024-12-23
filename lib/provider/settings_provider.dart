import 'dart:ui';

import 'package:ai_defender_tablet/dialog/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../globals.dart';
import '../helpers/toast_helper.dart';
import '../helpers/shared_pref.dart';
import '../routes.dart';
import 'base_provider.dart';

class SettingsProvider extends BaseProvider {
  List<String> list = ['Bluetooth','WiFi', 'Logout'];

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
        Globals.auth.signOut();
        SharedPref.prefs?.clear();
        context.go(AppPaths.wifi);
      }
    });

  }

  void showDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const CommonDialog(
                description: "Are you sure you want delete account?",
              ),
            )).then((value) async {
      if (value != null && value) {
        await deleteAccount().then((value) {
          SharedPref.prefs?.clear();
          context.go(AppPaths.login);
        });
      }
    });
  }


  Future<void> deleteAccount() async {
    Map<String, dynamic> data = {'isDeleted': true};
    await Globals.userReference.doc(Globals.firebaseUser?.uid).update(data);
    await Globals.deletedUserReference
        .doc(Globals.firebaseUser?.uid)
        .set({"deletedAt": DateTime.now()});
  }

}
