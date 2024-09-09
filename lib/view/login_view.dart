import 'package:ai_defender_tablet/constants/colors_constants.dart';
import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/decoration.dart';
import 'package:ai_defender_tablet/provider/login_provider.dart';
import 'package:ai_defender_tablet/widgets/primary_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/string_constants.dart';
import '../helpers/toast_helper.dart';
import '../helpers/keyboard_helper.dart';
import 'base_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginProvider>(
        builder: (context, provider, _) => GestureDetector(
              onTap: () {
                KeyboardHelper.hideKeyboard(context);
              },
              child: Scaffold(
                backgroundColor: kWhiteColor,
                body: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 48.w, vertical: 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello! Enter your Registered\nnumber to get started",
                        style: ViewDecoration.textStyleBoldUrbanist(
                            kBlackColor, 30.sp),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Text(
                        "We Will Text Message To Verify\nYour Phone Number",
                        style: ViewDecoration.textStyleMediumUrbanist(
                            kColor838BA1, 16.sp),
                      ),
                      SizedBox(
                        height: 48.h,
                      ),
                      Container(
                        height: 56.h,
                        decoration: BoxDecoration(
                            border: Border.all(color: kColorE8ECF4),
                            borderRadius: BorderRadius.circular(8.r),
                            color: kColorF7F8F9),
                        child: Row(
                          children: [
                            CountryCodePicker(
                              onChanged: (value) {
                                if (value.dialCode != null) {
                                  provider.dialCode = value.dialCode!;
                                }
                              },
                              initialSelection: 'US',
                              builder: (p0) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      const Icon(Icons.keyboard_arrow_down),
                                      SizedBox(width: 8.w,),

                                      if (p0?.flagUri != null) Image.asset(
                                        p0!.flagUri!,
                                        package: 'country_code_picker',
                                        width: 32,

                                      ),

                                    ],
                                  ),
                                );
                              },
                              showCountryOnly: false,
                              textStyle: ViewDecoration.textStyleMedium(
                                  kBlackColor, 20.sp),
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                            ),

                            Expanded(
                                child: TextFormField(
                              controller: _phoneController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              style: ViewDecoration.textStyleMedium(
                                  kBlackColor, 20.sp),
                              decoration: ViewDecoration
                                  .textFiledDecorationWithoutBorder(
                                      fillColor: kColorF7F8F9,
                                      hintText: 'Mobile Number'),
                            ))
                          ],
                        ),
                      ),
                      privacyPolicyWidget(provider),
                      SizedBox(
                        height: 24.h,
                      ),
                      Center(
                          child: provider.state == ViewState.busy
                              ? const CircularProgressIndicator()
                              : PrimaryButton(
                                  height: 56.h,
                                  width: 550.w,
                                  title: 'Send OTP',
                                  onPressed: () async {
                                    KeyboardHelper.hideKeyboard(context);
                                    if (_phoneController.text.trim().isEmpty) {
                                      ToastHelper.showErrorMessage(
                                          'Please enter mobile number');
                                    } else if (_phoneController.text
                                            .trim()
                                            .isNotEmpty &&
                                        _phoneController.text.trim().length <
                                            10) {
                                      ToastHelper.showErrorMessage(
                                          'Please enter valid mobile number');
                                    } else if (!provider.isCheckedPolicy) {
                                      ToastHelper.showErrorMessage(
                                          'Please accept terms of privacy policy');
                                    } else {
                                      await provider.loginUser(
                                          _phoneController.text.trim(),
                                          context);
                                    }
                                  },
                                  radius: 8.r))
                    ],
                  ),
                ),
              ),
            ));
  }

  privacyPolicyWidget(LoginProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
            value: provider.isCheckedPolicy,
            onChanged: (bool? value) {
              setState(() {
                provider.isCheckedPolicy = value ?? false;
              });
            }),
        Expanded(
          child: Text.rich(
            TextSpan(text: "I have read and agree with the ", children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    CommonFunction.openUrl(privacyUrl,
                        launchMode: LaunchMode.externalApplication);
                  },
                text: 'Privacy Policy',
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              )
            ]),
            textAlign: TextAlign.start,
            softWrap: true,
            style: const TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }
}
