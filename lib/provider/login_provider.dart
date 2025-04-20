import 'dart:ui';

import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../enums/viewstate.dart';
import '../globals.dart';
import '../helpers/shared_pref.dart';
import '../helpers/toast_helper.dart';
import '../models/user_model.dart';
import '../routes.dart';
import '../view/account_reinstate_view.dart';

class LoginProvider extends BaseProvider {
  bool _loginLoader = false;

  bool get loginLoader => _loginLoader;

  set loginLoader(bool value) {
    _loginLoader = value;
    customNotify();
  }

  bool _isCheckedPolicy = false;

  bool get isCheckedPolicy => _isCheckedPolicy;

  set isCheckedPolicy(bool value) {
    _isCheckedPolicy = value;
    customNotify();
  }

  String _dialCode = '+1';

  String get dialCode => _dialCode;

  set dialCode(String value) {
    _dialCode = value;
    customNotify();
  }

  Future<void> loginUser(String phone, BuildContext context) async {
    setState(ViewState.busy);
    Globals.auth.verifyPhoneNumber(
        phoneNumber: "$dialCode$phone",
        timeout: const Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException exception) {
          setState(ViewState.idle);
          ToastHelper.showErrorMessage(exception.message ?? '');
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          setState(ViewState.idle);
          ToastHelper.showMessage("OTP sent successfully");
          context.pushNamed(AppPaths.otp, extra: {
            'countryCode': dialCode,
            'phone': phone,
            'verificationId': verificationId
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(ViewState.idle);
          debugPrint("Timeout");
        });
  }

  Future<void> loginWithCompanyId(
      String companyId, BuildContext context) async {
    loginLoader = true;
    await Globals.userReference.doc(companyId).get().then((doc) async {
      loginLoader = false;
      if (doc.exists) {
        UserModel model =
            UserModel.fromSnapshot(doc.data() as Map<String, dynamic>);
        if (model.isDeleted != null && model.isDeleted!) {
          setState(ViewState.idle);
          context.pop();
          showDialog(
              context: Globals.navigatorKey.currentContext!,
              builder: (_) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: AccountReInstateView(model),
                  ));
        }else{
          SharedPref.prefs?.setBool(SharedPref.isLoggedIn, true);
          SharedPref.prefs?.setString(SharedPref.userId, companyId);
          context.go(AppPaths.download);
        }
      } else {
        ToastHelper.showErrorMessage('Company Id Not Exist.');
      }
    }).catchError((error, stackTrace) {
      loginLoader = false;
      debugPrint("error: $error");
    });
  }
}
