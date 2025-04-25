import 'dart:async';

import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/provider/otp_provider.dart';
import 'package:ai_defender_tablet/view/base_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../constants/colors_constants.dart';
import '../helpers/decoration.dart';
import '../helpers/keyboard_helper.dart';
import '../widgets/primary_button.dart';

class OtpView extends StatefulWidget {
  final String? countryCode;
  final String? phone;
  final String? verificationId;

  const OtpView({super.key, this.countryCode, this.phone, this.verificationId});

  @override
  OtpViewState createState() => OtpViewState();
}

class OtpViewState extends State<OtpView> {
  String pin = '';
  String fcmToken = '';

  int _start = 120; // Timer duration in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            // Handle timer completion here, e.g., enable resend button
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<OtpProvider>(
        onModelReady: (provider) async {
          provider.verificationId = widget.verificationId ?? '';
        },
        builder: (context, provider, _) => Scaffold(
              backgroundColor: kWhiteColor,
              appBar: CommonFunction.appBar('', context, showBack: true,
                  onBackPress: () {
                context.pop();
              }),
              body: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: 100.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "OTP Verification",
                      style: ViewDecoration.textStyleBoldUrbanist(kBlackColor, 30),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      "Enter the verification code we just sent on your mobile number.",
                      style:
                          ViewDecoration.textStyleMediumUrbanist(kColor838BA1, 16),
                    ),
                    SizedBox(
                      height: 32.h,
                    ),
                    OTPTextField(
                      length: 6,
                      width: 1.sw,
                      fieldWidth: (1.sw) / 8,
                      style: ViewDecoration.textStyleBold(kBlackColor, 22),
                      textFieldAlignment: MainAxisAlignment.spaceBetween,
                      fieldStyle: FieldStyle.box,
                      onCompleted: (pin) {
                        pin = pin;
                      },
                      onChanged: (value) {
                        pin = value;
                      },
                    ),
                    SizedBox(
                      height: 32.h,
                    ),
                    Center(
                        child: provider.verifyLoader
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : PrimaryButton(
                            height: 56.h,
                            width: 550.w,
                            title: 'Verify',
                            onPressed: () async {
                              if (pin.length == 6) {
                                _timer.cancel();
                                await provider.confirm(
                                    context, pin, fcmToken);
                                if (_start != 0) {
                                  startTimer();
                                }
                              }
                            },
                            radius: 8.r)),
                    SizedBox(
                      height: 24.h,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          KeyboardHelper.hideKeyboard(context);
                          if (_start == 0) {
                            await provider.loginUser(
                                '${widget.countryCode}${widget.phone}',
                                context);
                          }
                        },
                        child: Column(
                          children: [
                            Text(
                              "Didn’t received code? ",
                              style: ViewDecoration.textStyleMedium(
                                  kBlackColor, 18),
                            ),
                            Text(
                              _start == 0
                                  ? "Resend"
                                  : "Resend code after $_start seconds",
                              style: ViewDecoration.textStyleMedium(
                                  kColor35C2C1, 15),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
