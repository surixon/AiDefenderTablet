import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../globals.dart';
import '../helpers/shared_pref.dart';
import '../models/user_model.dart';
import '../routes.dart';
import 'base_provider.dart';

class AccountReInStateProvider extends BaseProvider {
  Future<void> navigateToHome(
      BuildContext context, UserModel model, String fcmToken) async {
    await updateFcmToken(fcmToken).then((value) {
      SharedPref.prefs?.setBool(SharedPref.isLoggedIn, true);
      context.go(AppPaths.dashboard);
    });
  }

  Future<void> updateFcmToken(String? fcmToken) async {
    Map<String, dynamic> data = { 'isDeleted': false};
    await Globals.userReference.doc(Globals.firebaseUser?.uid).update(data);
    await Globals.deletedUserReference.doc(Globals.firebaseUser?.uid).delete();
  }
}
