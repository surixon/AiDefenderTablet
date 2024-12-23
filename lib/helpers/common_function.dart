import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import 'package:url_launcher/url_launcher.dart';

import '../constants/colors_constants.dart';
import '../constants/image_constants.dart';
import '../widgets/image_view.dart';
import 'decoration.dart';

class CommonFunction {
  static PreferredSizeWidget appBar(String title,
      BuildContext context, {
        bool showBack = false,
        bool showSettings = false,
        bool showNext = false,
        VoidCallback? onBackPress,
        VoidCallback? onSettingsPress,
        VoidCallback? onNextClick,
      }) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: showBack
          ? GestureDetector(
        onTap: onBackPress,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, top: 8.h, bottom: 8.h),
          child: const ImageView(
            path: back,
          ),
        ),
      )
          : Container(),
      title: Text(
        title,
        style: ViewDecoration.textStyleBold(kBlackColor, 24.sp),
      ),
      centerTitle: true,
      actions: [
        showSettings
            ? GestureDetector(
          onTap: onSettingsPress,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const ImageView(
              path: settings,
            ),
          ),
        )
            : const SizedBox(),
        showNext
            ? GestureDetector(
          onTap: onNextClick,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Center(
              child: Text(
                'Next',
                style: ViewDecoration.textStyleSemiBold(kBlackColor, 20.sp),
              ),
            ),
          ),
        )
            : const SizedBox()
      ],
    );
  }

  static PreferredSizeWidget appBarWithButtons(String title,
      BuildContext context, {
        bool showBack = false,
        bool showAdd = false,
        bool showSetting = false,
        VoidCallback? onBackPress,
        VoidCallback? onAddPress,
        VoidCallback? onSettingPress,
      }) {
    return AppBar(
      elevation: 1,
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      leading: showBack
          ? GestureDetector(
        onTap: onBackPress,
        child: Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
          child: const Icon(
            Icons.arrow_back,
            size: 24,
            color: kWhiteColor,
          ),
        ),
      )
          : Container(),
      title: Text(
        title,
        style: ViewDecoration.textStyleBold(kWhiteColor, 24.sp),
      ),
      centerTitle: true,
      actions: [
        showSetting
            ? GestureDetector(
          onTap: onSettingPress,
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            child: Icon(
              Icons.settings,
              size: 32.w,
            ),
          ),
        )
            : const SizedBox()
      ],
    );
  }

  static Future<void> openUrl(String url, {LaunchMode? launchMode}) async {
    if (!await launchUrl(Uri.parse(url),
        mode: launchMode ?? LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  static String getDateFromTimeStamp(DateTime date, String format) {
    return DateFormat(format, 'en').format(date).toString();
  }

  static Future <void> showEnableLocationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enable Location Services"),
          content: const Text(
            "Location services are required for Wi-Fi scanning. Please enable them in your device settings.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings(); // Open location settings
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );
  }
}
