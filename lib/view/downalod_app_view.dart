import 'package:ai_defender_tablet/constants/colors_constants.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../constants/string_constants.dart';
import '../routes.dart';

class DownloadLoadAppView extends StatelessWidget {
  const DownloadLoadAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: CommonFunction.appBar(
        'Download App',
        context,
        showBack: false,
        onBackPress: () {
          context.pop();
        },
        onNextClick: () {
          context.go(AppPaths.dashboard);
        },
        showNext: true,
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Center(
                  child: Text(
                    "Download Android App",
                    style: ViewDecoration.textStyleBoldUrbanist(kBlackColor, 32.sp),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                QrImageView(
                  data: androidAppUrl,
                  version: QrVersions.auto,
                  size: 1.sw/3,
                ),

              ],
            ),
        
            Column(
              children: [
                Center(
                  child: Text(
                    "Download iOS App",
                    style: ViewDecoration.textStyleBoldUrbanist(kBlackColor, 32.sp),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                QrImageView(
                  data: iOSAppUrl,
                  version: QrVersions.auto,
                  size: 1.sw/3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
