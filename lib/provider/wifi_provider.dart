import 'dart:async';

import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../constants/channel_constants.dart';
import '../helpers/life_cycle_event_handler.dart';
import '../helpers/toast_helper.dart';

class WifiProvider extends BaseProvider {
  bool shouldCheckCan = true;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];

  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  bool get isStreaming => subscription != null;

  String? _sSSID;

  String? get sSSID => _sSSID;

  set sSSID(String? value) {
    _sSSID = value;
    notifyListeners();
  }

  bool isEnabled = false;

  bool isConnected = false;

  Future<void> startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      subscription =
          WiFiScan.instance.onScannedResultsAvailable.listen((result) {
        accessPoints = result;

        notifyListeners();
      });
    }
  }

  void stopListeningToScanResults() {
    subscription?.cancel();
    subscription = null;
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        ToastHelper.showErrorMessage("Cannot get scanned results: $can");

        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> checkWifiStatus() async {
    setState(ViewState.busy);
    await WiFiForIoTPlugin.isEnabled().then((val) async {
      isEnabled = val;
      if (isEnabled) {
        await WiFiForIoTPlugin.isConnected().then((val) {
          isConnected = val;
        });

        debugPrint("isConnected $isConnected");

        if (isConnected) {
          await getWifiDetails();
        } else {
          sSSID = null;
        }
      } else {
        sSSID = null;
      }
    });

    setState(ViewState.idle);
  }

  Future<void> openWifSetting() async {

    await WiFiForIoTPlugin.setEnabled(isEnabled, shouldOpenSettings: true);
  }

  Future<void> getWifiDetails() async {
    sSSID = await WiFiForIoTPlugin.getSSID();
    debugPrint("SSID $sSSID");
  }

  void lifeCycleEventHandler() {

    WidgetsBinding.instance
        .addObserver(LifecycleEventHandler(resumeCallBack: () async {
          if(subscription!=null){
            await checkWifiStatus();
          }

    }));
  }

  Future<void> overlayPermission(BuildContext context) async {
    try {
      ChannelConstants.platform.invokeMethod('overlayPermission');
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }
}
