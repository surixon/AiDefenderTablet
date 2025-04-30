import 'package:ai_defender_tablet/constants/colors_constants.dart';
import 'package:ai_defender_tablet/constants/dimensions_constants.dart';
import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/decoration.dart';
import 'package:ai_defender_tablet/provider/login_provider.dart';
import 'package:ai_defender_tablet/widgets/primary_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _companyIdController = TextEditingController(text: "net9CNjI9JglVepBmnby9u4h10q1");

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginProvider>(
        builder: (context, provider, _) => DefaultTabController(
          length: 2,
          child: Scaffold(

            body: Padding(
              padding:
                  const EdgeInsets.only(left: 36,right: 36,top: 80 ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelPadding: const EdgeInsets.all(8),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Text(
                        "login_with_phone".tr(),
                        style: ViewDecoration.textStyleBoldUrbanist(
                            kBlackColor, 18),
                      ),
                      Text("company_id".tr(),
                          style: ViewDecoration.textStyleBoldUrbanist(
                              kBlackColor, 18))
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    loginWithPhone(provider),
                    loginWithCompanyId(provider),
                  ]))
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
            style: const TextStyle(fontSize: 18),
          ),
        )
      ],
    );
  }

  loginWithPhone(LoginProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello! Enter your Registered\nnumber to get started",
            style: ViewDecoration.textStyleBoldUrbanist(kBlackColor, 30),
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            "We Will Text Message To Verify\nYour Phone Number",
            style: ViewDecoration.textStyleMediumUrbanist(kColor838BA1, 16),
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
                          const SizedBox(
                            width: 8,
                          ),
                          if (p0?.flagUri != null)
                            Image.asset(
                              p0!.flagUri!,
                              package: 'country_code_picker',
                              width: 40,
                            ),
                        ],
                      ),
                    );
                  },
                  showCountryOnly: false,
                  textStyle: ViewDecoration.textStyleMedium(kBlackColor, 20.sp),
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                ),
                Expanded(
                    child: TextFormField(
                  controller: _phoneController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  style: ViewDecoration.textStyleMedium(kBlackColor, 20),
                  decoration: ViewDecoration.textFiledDecorationWithoutBorder(
                      fillColor: kColorF7F8F9, hintText: 'Mobile Number'),
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
                        } else if (_phoneController.text.trim().isNotEmpty &&
                            _phoneController.text.trim().length < 10) {
                          ToastHelper.showErrorMessage(
                              'Please enter valid mobile number');
                        } else if (!provider.isCheckedPolicy) {
                          ToastHelper.showErrorMessage(
                              'Please accept terms of privacy policy');
                        } else {
                          await provider.loginUser(
                              _phoneController.text.trim(), context);
                        }
                      },
                      radius: 8.r))
        ],
      ),
    );
  }

  loginWithCompanyId(LoginProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello! Enter your Company ID\nto get started",
            style: ViewDecoration.textStyleBoldUrbanist(kBlackColor, 30),
          ),
          SizedBox(
            height: 48.h,
          ),
          Container(
            height: 56.h,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(color: kColorE8ECF4),
                borderRadius: BorderRadius.circular(8.r),
                color: kColorF7F8F9),
            child: Row(
              children: [

                Expanded(
                    child: TextFormField(
                  controller: _companyIdController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  style: ViewDecoration.textStyleMedium(kBlackColor, 20),
                  decoration: ViewDecoration.textFiledDecorationWithoutBorder(
                      fillColor: kColorF7F8F9, hintText: 'company_id'.tr()),
                ))
              ],
            ),
          ),
          privacyPolicyWidget(provider),
          SizedBox(
            height: 24.h,
          ),
          Center(
              child: provider.loginLoader
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      height: 56.h,
                      width: 550.w,
                      title: 'Login',
                      onPressed: () async {
                        KeyboardHelper.hideKeyboard(context);
                        if (_companyIdController.text.trim().isEmpty) {
                          ToastHelper.showErrorMessage(
                              'Please enter Company Id');
                        } else if (!provider.isCheckedPolicy) {
                          ToastHelper.showErrorMessage(
                              'Please accept terms of privacy policy');
                        } else {
                          await provider.loginWithCompanyId(
                              _companyIdController.text.trim(), context);
                        }
                      },
                      radius: 8.r))
        ],
      ),
    );
  }
}
