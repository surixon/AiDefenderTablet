import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors_constants.dart';
import '../helpers/decoration.dart';
import 'image_view.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final double radius;
  final String? iconPath;
  final Color? iconColor;
  final Color? color;

  final Color textColor;
  final double? fontSize;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.width,
    this.height,
    required this.radius,
    this.iconPath,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.color,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? kPrimaryColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color ?? kPrimaryColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          )),
        ),
        child: iconPath != null
            ? Row(
                children: [
                  ImageView(
                    path: iconPath!,
                    width: 14.w,
                    color: iconColor,
                    height: 12.h,
                  ),
                  SizedBox(
                    width: 16.w,
                  ),
                  Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: ViewDecoration.textStyleSemiBold(
                          textColor, fontSize ?? 20),
                    ),
                  ),
                ],
              )
            : Text(
                title,
                textAlign: TextAlign.center,
                style: ViewDecoration.textStyleSemiBold(
                    textColor, fontSize ?? 20),
              ),
      ),
    );
  }
}
