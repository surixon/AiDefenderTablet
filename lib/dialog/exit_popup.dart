import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors_constants.dart';
import '../helpers/decoration.dart';

Future<bool> showExitPopup(context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("do_you_want".tr()),
                const Expanded(child: SizedBox()),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          exit(0);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        child: Text("yes".tr(),
                            style: ViewDecoration.textStyleRegular(
                                Colors.white, 13.sp)),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      child: Text("no".tr(),
                          style: ViewDecoration.textStyleRegular(
                              kBlackColor, 13.sp)),
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}
