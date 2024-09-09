import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../enums/viewstate.dart';
import '../globals.dart';
import '../helpers/toast_helper.dart';
import '../routes.dart';

class LoginProvider extends BaseProvider{

  bool _isCheckedPolicy = false;

  bool get isCheckedPolicy => _isCheckedPolicy;

  set isCheckedPolicy(bool value) {
    _isCheckedPolicy = value;
    notifyListeners();
  }

  String _dialCode = '+1';

  String get dialCode => _dialCode;

  set dialCode(String value) {
    _dialCode = value;
    notifyListeners();
  }

  Future<void> loginUser(String phone, BuildContext context) async {
    debugPrint("Phone $phone");
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

}