import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors_constants.dart';
import '../enums/viewstate.dart';
import '../helpers/decoration.dart';
import '../models/user_model.dart';
import '../provider/account_reinstate_provider.dart';
import '../widgets/primary_button.dart';
import 'base_view.dart';

class AccountReInstateView extends StatefulWidget {
  final UserModel? model;
  final String fcmToken;

  const AccountReInstateView(this.model, this.fcmToken, {Key? key})
      : super(key: key);

  @override
  AccountReInstateViewState createState() => AccountReInstateViewState();
}

class AccountReInstateViewState extends State<AccountReInstateView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AccountReInStateProvider>(
        builder: (context, provider, _) => GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                backgroundColor: Colors.black.withOpacity(.2),
                body: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 18, 15, 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'account_reinstatement'.tr(),
                              style: ViewDecoration.textStyleSemiBold(
                                  kBlackColor, 18.sp),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'there_is_a_history'.tr(),
                              style: ViewDecoration.textStyleRegular(
                                  kBlackColor, 12.sp),
                            ),
                            SizedBox(
                              height: 22.h,
                            ),
                            provider.state == ViewState.busy
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : PrimaryButton(
                                    width: MediaQuery.of(context).size.width,
                                    height: 46,
                                    title: 'Reinstate Account',
                                    onPressed: () async {
                                      await provider.navigateToHome(context,
                                          widget.model!, widget.fcmToken);
                                    },
                                    radius: 8.r,
                                  ),
                            SizedBox(
                              height: 16.h,
                            ),
                            PrimaryButton(
                              width: MediaQuery.of(context).size.width,
                              height: 46,
                              color: kWhiteColor,
                              textColor: Theme.of(context).primaryColor,
                              title: 'cancel'.tr(),
                              onPressed: () async {
                                context.pop();
                              },
                              radius: 8.r,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
