import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors_constants.dart';
import '../helpers/decoration.dart';

class CommonDialog extends StatefulWidget {

  final String? description;

  const CommonDialog({Key? key,  this.description})
      : super(key: key);

  @override
  CommonDialogState createState() => CommonDialogState();
}

class CommonDialogState extends State<CommonDialog> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: kBlackColor.withOpacity(.5),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Text(
                          widget.description??'',
                          textAlign: TextAlign.center,
                          style: ViewDecoration.textStyleSemiBold(
                              kBlackColor, 18.sp),
                        ),
                      ),
                      SizedBox(
                        height: 42.h,
                      ),
                      SizedBox(
                          height: 46.h,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.r)),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                context.pop(true);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                              child: Text(
                                "Confirm",
                                textAlign: TextAlign.center,
                                style: ViewDecoration.textStyleMedium(
                                    Colors.white, 14.sp),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 8.h,
                      ),
                      SizedBox(
                          height: 46.h,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.r)),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                context.pop();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                              child: Text(
                                'Cancel',
                                style: ViewDecoration.textStyleMedium(
                                    Theme.of(context).primaryColor, 14.sp),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
