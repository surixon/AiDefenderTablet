import 'dart:ui';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../enums/viewstate.dart';
import '../globals.dart';
import '../helpers/toast_helper.dart';
import '../helpers/shared_pref.dart';
import '../models/user_model.dart';
import '../routes.dart';
import '../view/account_reinstate_view.dart';

class OtpProvider extends BaseProvider {
  String verificationId = '';

  bool _verifyLoader = false;

  bool get verifyLoader => _verifyLoader;

  set verifyLoader(bool value) {
    _verifyLoader = value;
    notifyListeners();
  }

  Future<void> loginUser(String phone, BuildContext context) async {
    debugPrint("Phone $phone");
    setState(ViewState.busy);
    Globals.auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (AuthCredential credential) async {
          setState(ViewState.idle);
        },
        verificationFailed: (FirebaseAuthException exception) {
          setState(ViewState.idle);
          ToastHelper.showErrorMessage(exception.message ?? '');
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          setState(ViewState.idle);
          ToastHelper.showMessage("OTP sent successfully");
          verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(ViewState.idle);
          verificationId = verificationId;
          debugPrint(verificationId);
          debugPrint("Timeout");
        });
  }

  Future<void> confirm(
      BuildContext context, String code, String fcmToken) async {
    verifyLoader = true;
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);

      await Globals.auth
          .signInWithCredential(credential)
          .then((UserCredential? userCredential) async {
        if (userCredential != null) {
          await createUser(context, fcmToken).then((value) {
            verifyLoader = false;
            SharedPref.prefs?.setBool(SharedPref.isLoggedIn, true);

            context.go(AppPaths.download);
          });
        } else {
          verifyLoader = false;
          ToastHelper.showErrorMessage("Something went wrong!");
        }
      });
    } on FirebaseAuthException catch (e) {
      verifyLoader = false;
      debugPrint("Error ${e.code}");
      if (e.code == 'invalid-verification-code') {
        ToastHelper.showErrorMessage('The entered OTP is In-Valid');
      } else if (e.code == 'session-expired') {
        ToastHelper.showErrorMessage('The entered OTP is In-Valid');
      } else {
        ToastHelper.showErrorMessage("Something went wrong!");
      }
    }
  }

  Future<void> createUser(BuildContext context, String fcmToken) async {
    UserModel? model;
    var reference = Globals.userReference.doc(Globals.firebaseUser?.uid);
    await reference.get().then((doc) async {
      if (doc.exists) {
        model = UserModel.fromSnapshot(doc.data() as Map<String, dynamic>);
        if (model?.isDeleted != null && model!.isDeleted!) {
          setState(ViewState.idle);
          context.pop();
          showDialog(
              context: Globals.navigatorKey.currentContext!,
              builder: (_) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: AccountReInstateView(model),
                  ));
        }
      } else {
        Map<String, dynamic> data = {'createdAt': DateTime.now()};
        await Globals.userReference.doc(Globals.firebaseUser?.uid).set(data);
        SharedPref.prefs
            ?.setString(SharedPref.userId, Globals.firebaseUser?.uid ?? '');
      }
    });
  }
}
