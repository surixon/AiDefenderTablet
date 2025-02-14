import 'dart:async';
import 'dart:ui';
import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/decoration.dart';
import 'package:ai_defender_tablet/helpers/keyboard_helper.dart';
import 'package:ai_defender_tablet/provider/dashboard_provider.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants/colors_constants.dart';
import '../constants/image_constants.dart';
import '../dialog/common_dialog.dart';
import '../helpers/common_function.dart';
import '../helpers/toast_helper.dart';
import '../widgets/image_view.dart';
import '../widgets/primary_button.dart';
import 'base_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  DashboardViewState createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  DashboardProvider? _provider;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _provider?.scanResults = results;
      debugPrint("scanResults ${_provider?.scanResults.length}");
    }, onError: (e) {
      ToastHelper.showErrorMessage("Scan Error: $e");
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DashboardProvider>(
      onModelReady: (provider) async {
        _provider = provider;
        provider.loadJson().then((_) async {
          await provider.getLocationName().then((_) async {
            if (provider.selectedLocation != null) {
              await provider.startScanning(context);
            }
          });
        });
      },
      builder: (context, provider, _) => Scaffold(
        backgroundColor: kWhiteColor,
        appBar: CommonFunction.appBar('Scan', context, showSettings: true,
            onSettingsPress: () {
          context.pushNamed(AppPaths.settings).then((_) async {
            await provider.getLocationName();
          });
        }),
        body: GestureDetector(
          onTap: () {
            KeyboardHelper.hideKeyboard(context);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  provider.state == ViewState.busy
                      ? const LinearProgressIndicator(
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                        )
                      : const SizedBox(),
                  SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 96.w, vertical: 4.h),
                      child: Column(
                        children: [
                          Visibility(
                            visible: provider.isScanning,
                            child: Center(
                              child: Text(
                                "Scanning in progress, please check details on your phone",
                                style: ViewDecoration.textStyleSemiBold(
                                    kBlackColor, 18.sp),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 220.h,
                            height: 220.h,
                            decoration: BoxDecoration(
                              color: provider.isScanning
                                  ? kColor0A9059
                                  : kColorFC5B2D,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kBlackColor.withOpacity(.65),
                                  spreadRadius: 0,
                                  blurRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 140.h,
                                height: 140.h,
                                decoration: BoxDecoration(
                                  color: provider.isScanning
                                      ? kColor0A9059
                                      : kColorFC5B2D,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kBlackColor.withOpacity(.65),
                                      spreadRadius: 0,
                                      blurRadius: 2,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                    child: provider.isScanning
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Scanning',
                                                style: ViewDecoration
                                                    .textStyleSemiBold(
                                                        kWhiteColor, 16.sp),
                                              ),
                                              Text(
                                                '...',
                                                style: ViewDecoration
                                                    .textStyleSemiBold(
                                                        kWhiteColor, 16.sp),
                                              )
                                                  .animate(
                                                    onPlay: (controller) =>
                                                        controller
                                                            .repeat(), // loop
                                                  )
                                                  .fadeIn(
                                                      delay: 500.ms,
                                                      duration: 1500.ms)
                                            ],
                                          )
                                        : Text(
                                            'Stopped',
                                            style: ViewDecoration
                                                .textStyleSemiBold(
                                                    kWhiteColor, 16.sp),
                                          )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16.h,
                          ),
                          SizedBox(
                            width: 1.sw / 2,
                            child: Column(
                              children: [
                                provider.locationList.isNotEmpty
                                    ? DropdownButtonFormField(
                                        isExpanded: true,
                                        value: provider.selectedLocation,
                                        decoration: const InputDecoration(
                                          labelText: 'Select a Location',
                                          border: OutlineInputBorder(),
                                        ),
                                        items:
                                            provider.locationList.map((data) {
                                          return DropdownMenuItem(
                                            value: data?.id,
                                            child: Text(
                                              data?.data()['locationName'],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: provider.isScanning
                                            ? null
                                            : (dynamic value) {
                                                provider.selectedLocation =
                                                    value;
                                              })
                                    : TextButton(
                                        onPressed: () {
                                          context
                                              .pushNamed(
                                                  AppPaths.addLocationView)
                                              .then((id) async {
                                            await provider
                                                .getLocationName()
                                                .then((__) {
                                              if (id != null) {
                                                provider.selectedLocation =
                                                    id.toString();
                                              }
                                            });
                                          });
                                        },
                                        child: Text('ADD LOCATION',
                                            style: ViewDecoration
                                                .textStyleSemiBold(
                                                    kColor0294EA, 22, true)),
                                      ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                _itemBuilder(
                                    'Last Scan :',
                                    provider.lastScan == null
                                        ? ''
                                        : CommonFunction.getDateFromTimeStamp(
                                            provider.lastScan!,
                                            'MM-dd-yyyy HH:mm')),
                                SizedBox(
                                  height: 12.h,
                                ),
                                _itemBuilder(
                                    'Next Scan :',
                                    provider.nextScan == null
                                        ? ''
                                        : CommonFunction.getDateFromTimeStamp(
                                            provider.nextScan!,
                                            'MM-dd-yyyy HH:mm')),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          PrimaryButton(
                              height: 56.h,
                              width: 1.sw / 2,
                              title: provider.isScanning
                                  ? 'Stop Scan'
                                  : 'Start Scan',
                              onPressed: () async {
                                if (provider.isScanning) {
                                  showDialog(
                                      context: context,
                                      builder: (_) => BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 5, sigmaY: 5),
                                            child: const CommonDialog(
                                              description:
                                                  "Do you want to stop session?",
                                            ),
                                          )).then((value) async {
                                    if (value != null && value) {
                                      final bool isConnected =
                                          await InternetConnectionChecker
                                              .instance.hasConnection;
                                      if (isConnected) {
                                        provider.stopCron();
                                      } else {
                                        ToastHelper.showErrorMessage(
                                            'Device is not connected to the internet');
                                      }
                                    }
                                  });
                                } else {
                                  if (provider.selectedLocation == null) {
                                    ToastHelper.showErrorMessage(
                                        'Please select location');
                                  } else {
                                    await InternetConnectionChecker
                                        .instance.hasConnection
                                        .then((isConnected) async {
                                      if (isConnected) {
                                        await provider
                                            .updateLocation()
                                            .then((_) async {
                                          await provider.startScanning(context);
                                        });
                                      } else {
                                        ToastHelper.showErrorMessage(
                                            'Device is not connected to the internet');
                                      }
                                    });
                                  }
                                }
                              },
                              radius: 8.r),
                          SizedBox(
                            height: 40.h,
                          ),
                          Center(
                            child: ImageView(
                              width: 1.sw / 2,
                              path: logo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              provider.loader
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: kColorFC5B2D,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  _itemBuilder(String title, String subTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: ViewDecoration.textStyleSemiBold(
              kBlackColor.withOpacity(.6), 22.sp),
        ),
        SizedBox(
          width: 16.w,
        ),
        Text(subTitle,
            style: ViewDecoration.textStyleSemiBold(kBlackColor, 22.sp)),
      ],
    );
  }
}
