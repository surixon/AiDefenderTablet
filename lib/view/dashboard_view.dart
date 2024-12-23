import 'dart:async';

import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/decoration.dart';
import 'package:ai_defender_tablet/helpers/keyboard_helper.dart';
import 'package:ai_defender_tablet/provider/dashboard_provider.dart';
import 'package:ai_defender_tablet/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors_constants.dart';
import '../constants/image_constants.dart';
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
            await checkBluetooth(provider);
          });
        });

      },
      builder: (context, provider, _) => Scaffold(
        backgroundColor: kWhiteColor,
        appBar: CommonFunction.appBar('Scan', context, showSettings: true,
            onSettingsPress: () {
          context.pushNamed(AppPaths.settings);
        }),
        body: GestureDetector(
          onTap: () {
            KeyboardHelper.hideKeyboard(context);
          },
          child: SingleChildScrollView(
            child: Column(
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
                        Center(
                          child: Text(
                            "Scanning in progress, please check details on your phone",
                            style: ViewDecoration.textStyleSemiBold(
                                kBlackColor, 18.sp),
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
                                          style:
                                              ViewDecoration.textStyleSemiBold(
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
                              !provider.isScanning
                                  ? TextFormField(
                                      decoration:
                                          ViewDecoration.textFiledDecoration(
                                              hintText: "Location"),
                                      onChanged: (value) {
                                        provider.location = value;
                                      },
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: TextEditingController(
                                          text: provider.location),
                                      style: ViewDecoration.textStyleMedium(
                                          kBlackColor, 20.sp),
                                    )
                                  : _itemBuilder(
                                      'Location :', provider.location),
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
                                provider.isScanning = false;
                                provider.stopCron();
                              } else {
                                provider.isScanning = true;
                                //await provider.startWifiScanning(context);

                                await provider.onScanPressed().then((_) async {
                                  await provider.scanWifi().then((value) async {
                                    await provider.uploadData().then((value) {
                                      provider.startCron();
                                    });
                                  });
                                });
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

  Future<void> checkBluetooth(DashboardProvider provider) async {
    final state = await FlutterBluePlus.state.first;

    debugPrint("Status Bluetooth ${state}");

    if (state != BluetoothAdapterState.on) {
      showBluetoothDialog(provider);
    } else {
      startScan(provider);
    }
  }

  void showBluetoothDialog(DashboardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Required'),
        content:
            const Text('Please turn on Bluetooth to continue using this app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startScan(provider); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await FlutterBluePlus.turnOn(); // Request to enable Bluetooth
              startScan(provider);
            },
            child: const Text('Turn On'),
          ),
        ],
      ),
    );
  }

  Future<void> startScan(DashboardProvider provider) async {
    await provider.updateWifiName();
    await provider.onScanPressed().then((_) async {
      await provider.scanWifi().then((value) async {
        await provider.uploadData().then((value) {
          provider.startCron();
        });
      });
    });
  }
}
