import 'package:ai_defender_tablet/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors_constants.dart';
import '../enums/viewstate.dart';
import '../helpers/common_function.dart';
import '../helpers/decoration.dart';
import '../provider/settings_provider.dart';
import 'base_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsProvider>(
        builder: (context, provider, _) => Scaffold(
              appBar: CommonFunction.appBarWithButtons("Settings", context,
                  showBack: true, onBackPress: () {
                context.pop();
              }),
              body: Stack(
                children: [
                  ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 20.h),
                      itemBuilder: (context, index) =>
                          _itemBuilder(context, index, provider),
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: provider.list.length),
                  provider.state == ViewState.busy
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const SizedBox()
                ],
              ),
            ));
  }

  _itemBuilder(BuildContext context, int index, SettingsProvider provider) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            context.pushNamed(AppPaths.wifi,extra: {'showBack':'true'});
            break;

          case 1:
            provider.logout(context);
            break;
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          provider.list[index],
          style: ViewDecoration.textStyleMediumUrbanist(kBlackColor, 20.sp),
        ),
      ),
    );
  }
}
