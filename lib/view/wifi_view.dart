import 'package:ai_defender_tablet/constants/colors_constants.dart';
import 'package:ai_defender_tablet/constants/image_constants.dart';
import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/decoration.dart';
import 'package:ai_defender_tablet/provider/wifi_provider.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:ai_defender_tablet/view/base_view.dart';
import 'package:ai_defender_tablet/widgets/image_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiView extends StatefulWidget {
  final String? showBack;

  const WifiView({super.key, this.showBack});

  @override
  WifiViewState createState() => WifiViewState();
}

class WifiViewState extends State<WifiView> {
  WifiProvider? _wifiProvider;

  @override
  Widget build(BuildContext context) {
    return BaseView<WifiProvider>(
        onModelReady: (provider) async {
          _wifiProvider = provider;
          // provider.overlayPermission(context);
          await provider.checkLocationServices(context);
          //provider.lifeCycleEventHandler();
        },
        builder: (context, provider, _) => Scaffold(
              backgroundColor: kBgColor,
              appBar: CommonFunction.appBar('wifi'.tr(), context,
                  showBack: widget.showBack == 'true', onBackPress: () {
                context.pop();
              }, onNextClick: () {
                context.pushNamed(AppPaths.login);
              },
                  showNext: (provider.sSSID != null &&
                      provider.sSSID!.isNotEmpty &&
                      widget.showBack != 'true')),
              body: provider.state == ViewState.busy
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 16.h),
                      itemBuilder: (context, index) => _wifiItemBuilder(
                          context, provider.accessPoints[index], provider),
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 12.h,
                        );
                      },
                      itemCount: provider.accessPoints.length),
            ));
  }

  _wifiItemBuilder(BuildContext context, WiFiAccessPoint accessPoint,
      WifiProvider provider) {
    final signalIcon = accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return GestureDetector(
      onTap: () {
        provider.openWifSetting();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: kGreyECECEC,
        ),
        child: Row(
          children: [
            Icon(signalIcon,size: 32,),
            SizedBox(
              width: 16.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accessPoint.ssid.isNotEmpty
                        ? accessPoint.ssid
                        : "**EMPTY**",
                    style: ViewDecoration.textStyleBold(kBlackColor, 20),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text(
                    accessPoint.capabilities,
                    style: ViewDecoration.textStyleRegular(
                        kBlackColor.withOpacity(.5), 16),
                  ),
                ],
              ),
            ),
            provider.sSSID == accessPoint.ssid
                ? Row(
                    children: [
                      SizedBox(
                        width: 16.w,
                      ),
                      Text('Connected',
                          style: ViewDecoration.textStyleSemiBold(
                              Colors.green, 18))
                    ],
                  )
                : const SizedBox(),
            SizedBox(
              width: 16.w,
            ),
            const ImageView(
              path: settings,
              width: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wifiProvider?.stopListeningToScanResults();
    super.dispose();
  }
}
