import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/shared_pref.dart';
import 'package:ai_defender_tablet/models/ai_defender_model.dart';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants/channel_constants.dart';
import '../globals.dart';
import 'package:network_tools/network_tools.dart';

import '../locator.dart';
import '../models/device_model.dart';
import '../notifications/send_notification.dart';
import '../services/fetch_data_expection.dart';

class DashboardProvider extends BaseProvider {
  SendNotification sendNotification = locator<SendNotification>();

  final Set<Host> _hosts = <Host>{};
  final Set<DeviceModel> _devices = <DeviceModel>{};
  List<AiDefenderModel> aiDefenderList = [];
  DateTime? lastScan;
  DateTime? nextScan;
  final cron = Cron();
  Timer? timer;
  List<dynamic> hideNotification = [];

  bool _newDeviceFounded = false;
  bool _suspiciousDeviceFounded = false;
  bool _remoteDeviceFounded = false;

  String fcmToken = '';
  bool notifyNewDevice = false;
  bool notifySuspiciousDevice = false;
  bool notifyRemoteDevice = false;

  String location = '';

  bool _isScanning = true;

  bool get isScanning => _isScanning;

  set isScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  Future<void> scanWifi() async {
    setState(ViewState.busy);
    lastScan = DateTime.now();
    nextScan = lastScan?.add(const Duration(hours: 1));

    await Globals.userReference
        .doc(Globals.firebaseUser?.uid)
        .get()
        .then((value) {
      Map<String, dynamic> userDetails = value.data() as Map<String, dynamic>;

      hideNotification = userDetails['hideNotification'] ?? [];
      fcmToken = userDetails['fcm'];

      if (userDetails['notify'] != null) {
        notifyNewDevice = userDetails['notify']['newDevice'];
        notifySuspiciousDevice = userDetails['notify']['suspicious'];
        notifyRemoteDevice = userDetails['notify']['remote'];
      }
    });

    Globals.userReference.doc(Globals.firebaseUser?.uid).update({
      'location': location,
      'lastScan': lastScan,
      'nextScan': nextScan,
      'isScan': true
    });

    /*if (aiDefenderList.isEmpty) {
      await getAiDefender();
    }*/

    final scanner = LanScanner(debugLogging: true);
    final hosts = await scanner.quickIcmpScanAsync(
      ipToCSubnet(await NetworkInfo().getWifiIP() ?? ''),
    );
    _devices.clear();
    _hosts.clear();
    _hosts.addAll(hosts);
    await Future.forEach(_hosts, (element) async {
      bool isOpen80 = (await PortScannerService.instance
              .isOpen(element.internetAddress.address, 80)) !=
          null;
      bool isOpen554 = (await PortScannerService.instance
              .isOpen(element.internetAddress.address, 554)) !=
          null;

      if (!hideNotification.contains(element.internetAddress.address) &&
          isOpen554 &&
          !isOpen80 &&
          notifySuspiciousDevice) {
        await sendNotification.sendNotification(
            'suspicious_device',
            'Ai Defender',
            "Suspicious Device Found (${element.internetAddress.address})",
            fcmToken);
      }

      if (!hideNotification.contains(element.internetAddress.address) &&
          isOpen80 &&
          !isOpen554 &&
          notifyRemoteDevice) {
        await sendNotification.sendNotification(
            'remote_device',
            'Ai Defender',
            "Remote Accessible Device Found (${element.internetAddress.address})",
            fcmToken);
      }

      if (!hideNotification.contains(element.internetAddress.address) &&
          isOpen80 &&
          isOpen554 &&
          notifyRemoteDevice) {
        await sendNotification.sendNotification(
            'remote_device',
            'Ai Defender',
            "Remote Accessible Device Found (${element.internetAddress.address})",
            fcmToken);
      }

      var macAddress =
          await getMacAddressFromIpAddress(element.internetAddress.host);
      List<int> ports = [isOpen80 ? 80 : 0, isOpen554 ? 554 : 0];

      _devices
          .add(DeviceModel(element.internetAddress.address, ports, macAddress));
    });

    setState(ViewState.idle);
  }

  Future<void> startWifiScanning(BuildContext context) async {
    try {
      ChannelConstants.platform
          .invokeMethod('startScan', {'uid': Globals.firebaseUser?.uid ?? ''});
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }



  Future<String?> getMacAddressFromIpAddress(String ipAddress) async {
    try {
      return await ChannelConstants.platform
          .invokeMethod('getMacAddressFromIpAddress', ipAddress);
    } on PlatformException catch (e) {
      return "Error: ${e.message}";
    }
  }

  Future<String> getMac(String macAddress) async {
    setState(ViewState.busy);
    try {
      if (macAddress.isEmpty) {
        setState(ViewState.idle);
        return '';
      } else {
        var model = await api.getMacAddress(macAddress);
        setState(ViewState.idle);
        return model;
      }
      /* if (model.success != null) {
        setState(ViewState.idle);
        return model;
      } else {
        setState(ViewState.idle);
        return null;
      }*/
    } on FetchDataException catch (e) {
      setState(ViewState.idle);
      return '';
    } on SocketException catch (e) {
      setState(ViewState.idle);
      return '';
    }
  }

  Future<void> uploadData() async {
    List<dynamic> oldIpAddresses = [];
    if (SharedPref.prefs?.getString(SharedPref.oldIpAddresses) != null) {
      oldIpAddresses =
          jsonDecode(SharedPref.prefs!.getString(SharedPref.oldIpAddresses)!);
    }
    List<String> ipAddresses = [];
    List<Map<String, dynamic>> scanList = [];
    await Future.forEach(_devices, (element) async {
      String? macAddress;
      if (element.macAddress != null) {
        macAddress = await getMac(element.macAddress!);
        debugPrint("Response $macAddress");
      }
      scanList.add({
        'ports': element.ports,
        'ip': element.ip,
        'macAddress': element.macAddress,
        'brand': macAddress
      });
      ipAddresses.add(element.ip ?? '');

      if (!hideNotification.contains(element.ip) &&
          !oldIpAddresses.contains(element.ip) &&
          notifyNewDevice) {
        sendNotification.sendNotification('new_device', 'Ai Defender',
            "New Device Found (${element.ip})", fcmToken);
      }
    });

    SharedPref.prefs
        ?.setString(SharedPref.oldIpAddresses, json.encode(ipAddresses));

    var request = {
      'dateTime': DateTime.now(),
      'uid': Globals.firebaseUser?.uid,
      'scan': scanList,
      'dateOnly':
          CommonFunction.getDateFromTimeStamp(DateTime.now(), 'yyyyMMdd')
    };
    await Globals.scanReference.doc().set(request);

    /*await Globals.userReference
        .doc(Globals.firebaseUser?.uid)
        .get()
        .then((value) async {
      Map<String, dynamic> userDetails = value.data() as Map<String, dynamic>;

      if (userDetails['fcm'] != null && userDetails['notify'] != null) {
        if (_newDeviceFounded &&  userDetails['notify']['newDevice']) {
          await sendNotification.sendNotification('new_device', 'Ai Defender',
              "New Device Found", userDetails['fcm']);
          _newDeviceFounded = false;
        }

        if (_suspiciousDeviceFounded &&  userDetails['notify']['suspicious']) {
          await sendNotification.sendNotification('suspicious_device',
              'Ai Defender', "Suspicious Device Found", userDetails['fcm']);
          _suspiciousDeviceFounded = false;
        }

        if (_remoteDeviceFounded &&  userDetails['notify']['remote']) {
          await sendNotification.sendNotification(
              'remote_device',
              'Ai Defender',
              "Remote Accessible Device Found",
              userDetails['fcm']);
          _remoteDeviceFounded = false;
        }
      }

    });*/
  }

/*  Future<void> getAiDefender() async {
    Globals.aiDefenderReference.get().then((value) async {
      await Future.forEach(value.docs, (element) {
        var model = AiDefenderModel.fromSnapshot(element.data());
        model.ID = element.id;
        aiDefenderList.add(model);
      });
    });
  }*/

  Future<void> updateWifiName() async {
    WakelockPlus.enable();
    final wifiName = await NetworkInfo().getWifiName();
    Globals.userReference
        .doc(Globals.firebaseUser?.uid)
        .update({'wifiName': wifiName});
  }

  startCron() {
    timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      await scanWifi().then((value) async {
        await uploadData();
      });
    });
  }

  stopCron() async {
    timer?.cancel();
    Globals.userReference
        .doc(Globals.firebaseUser?.uid)
        .update({'lastScan': lastScan, 'nextScan': null, 'isScan': false});
  }
}
