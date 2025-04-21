import 'package:ai_defender_tablet/helpers/shared_pref.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:ai_defender_tablet/widgets/primary_button.dart';
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
        onModelReady: (provider) {
          provider.loadOptionList();
        },
        builder: (context, provider, _) => Scaffold(
              appBar: CommonFunction.appBarWithButtons("Settings", context,
                  showBack: true, onBackPress: () {
                context.pop();
              }),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                SharedPref.prefs
                                        ?.getString(SharedPref.userId) ??
                                    '',
                                style: ViewDecoration.textStyleMedium(
                                    Colors.blue, 20),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PrimaryButton(
                                height: 46,
                                title: "Copy",
                                onPressed: () {
                                  provider.copyIdToClipboard();
                                },
                                radius: 8.r)
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            itemBuilder: (context, index) => _itemBuilder(
                                context, provider.list[index], provider),
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                            itemCount: provider.list.length),
                      ),
                    ],
                  ),
                  provider.state == ViewState.busy
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const SizedBox()
                ],
              ),
            ));
  }

  _itemBuilder(BuildContext context, String title, SettingsProvider provider) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case "Location":
            context.pushNamed(AppPaths.locations);
            break;

          case "Bluetooth":
            context.pushNamed(AppPaths.bluetooth, extra: {'showBack': 'true'});
            break;

          case "WiFi":
            context.pushNamed(AppPaths.wifi, extra: {'showBack': 'true'});
            break;

          case "Logout":
            provider.logout(context);
            break;
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          title,
          style: ViewDecoration.textStyleMediumUrbanist(kBlackColor, 20),
        ),
      ),
    );
  }
}
