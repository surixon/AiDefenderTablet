import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/shared_pref.dart';
import 'package:ai_defender_tablet/helpers/toast_helper.dart';
import 'package:ai_defender_tablet/models/ai_defender_model.dart';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../constants/channel_constants.dart';
import '../globals.dart';
import 'package:network_tools/network_tools.dart';
import '../locator.dart';
import '../models/device_model.dart';
import '../notifications/send_notification.dart';
import '../services/fetch_data_expection.dart';

class DashboardProvider extends BaseProvider {
  bool _loader = true;

  bool get loader => _loader;

  set loader(bool value) {
    _loader = value;
    notifyListeners();
  }

  SendNotification sendNotification = locator<SendNotification>();
  Map<String, String>? prefixes;

  final Set<Host> _hosts = <Host>{};
  final Set<DeviceModel> _devices = <DeviceModel>{};
  List<AiDefenderModel> aiDefenderList = [];
  DateTime? lastScan;
  DateTime? nextScan;
  final Cron cron = Cron();
  Timer? timer;
  List<dynamic> hideNotification = [];
  List<ScanResult> scanResults = [];

  String fcmToken = '';
  bool notifyNewDevice = false;
  bool notifySuspiciousDevice = false;
  bool notifyRemoteDevice = false;
  bool btScan = true;
  bool wifiScan = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>?> locationList = [];

  String? selectedLocation;

  bool _isScanning = false;

  bool get isScanning => _isScanning;

  set isScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  Future<void> startWifiScan() async {
    setState(ViewState.busy);
    lastScan = DateTime.now();
    nextScan = lastScan?.add(const Duration(minutes: 20));

    await Globals.locationReference.doc(selectedLocation).update({
      'lastScan': lastScan,
      'nextScan': nextScan,
      'isScan': true
    }).then((value) {});

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
      String? brand;
      if (element.macAddress != null && element.macAddress!.length > 7) {
        //macAddress = await getMac(element.macAddress!);
        //debugPrint("Response $macAddress");
        String macPrefix = element.macAddress!.replaceAll(RegExp(r'[:\-]'), "");
        brand = prefixes?[macPrefix.substring(0, 6).toUpperCase()];
      }

      scanList.add({
        'ports': element.ports,
        'ip': element.ip,
        'macAddress': element.macAddress,
        'brand': brand
      });
      ipAddresses.add(element.ip ?? '');

      if (!hideNotification.contains(element.ip) &&
          !oldIpAddresses.contains(element.ip) &&
          notifyNewDevice) {
        sendNotification.sendNotification(
            'new_device',
            'Ai Defender',
            "New${_getDeviceName(element.ports)}Device Found (${element.ip})",
            fcmToken);
      }
    });

    SharedPref.prefs
        ?.setString(SharedPref.oldIpAddresses, json.encode(ipAddresses));

    List<dynamic> bluetoothScanList = [];

    await Future.forEach(scanResults, (bluetooth) async {
      String macPrefix =
          bluetooth.device.remoteId.str.replaceAll(RegExp(r'[:\-]'), "");

      String? companyName = prefixes?[macPrefix.substring(0, 6).toUpperCase()];

      bluetoothScanList.add({
        'rssi': bluetooth.rssi,
        'device': (companyName == null) ? 'Genric' : companyName,
        'bluetoothName': bluetooth.device.platformName,
        'name': bluetooth.device.remoteId.str,
        'txPowerLevel': bluetooth.advertisementData.txPowerLevel,
        'appearance':
            '0x${bluetooth.advertisementData.appearance?.toRadixString(16)}',
        'manufacturer':
            getNiceManufacturerData(bluetooth.advertisementData.msd),
      });
    });

    var request = {
      'dateTime': DateTime.now(),
      'uid': Globals.firebaseUser?.uid,
      'scan': scanList,
      'locationId': selectedLocation,
      'bluetoothScan': bluetoothScanList,
      'dateOnly':
          CommonFunction.getDateFromTimeStamp(DateTime.now(), 'yyyyMMdd')
    };
    await Globals.scanReference.doc().set(request);
  }

  /*Future<void> updateWifiName() async {


    await NetworkInfo().getWifiName().then((wifiName) async {
      debugPrint("Wifi Name $wifiName");
      debugPrint("User ID ${Globals.firebaseUser?.uid}");
      await Globals.userReference
          .doc(Globals.firebaseUser?.uid)
          .update({'wifiName': wifiName});
      debugPrint("Date Uploaded ${Globals.firebaseUser?.uid}");
    });
  }*/

  startCron() async {
    var bluetoothAdapterState = await FlutterBluePlus.adapterState.first;
    if (btScan &&
        !wifiScan &&
        bluetoothAdapterState == BluetoothAdapterState.on) {
      await startBluetoothScan().then((_) async {
        await uploadData();
      });
    }

    if (!btScan && wifiScan) {
      scanResults.clear();
      await startWifiScan().then((value) async {
        await uploadData();
      });
    }

    if (btScan && wifiScan) {
      await startBluetoothScan().then((_) async {
        await startWifiScan().then((_) async {
          await uploadData();
        });
      });
    }

    debugPrint("btScan $btScan");
    if (btScan) {
      checkIsBluetoothDeviceWithIn3Feet();
    }

    timer = Timer.periodic(const Duration(minutes: 20), (timer) async {
      await getUserDetails().then((_) async {
        if (btScan &&
            !wifiScan &&
            bluetoothAdapterState == BluetoothAdapterState.on) {
          await startBluetoothScan().then((_) async {
            await uploadData();
          });
        }

        if (!btScan && wifiScan) {
          await startWifiScan().then((value) async {
            await uploadData();
          });
        }

        if (btScan && wifiScan) {
          await startBluetoothScan().then((_) async {
            await startWifiScan().then((_) async {
              await uploadData();
            });
          });
        }

        if (btScan) {
          checkIsBluetoothDeviceWithIn3Feet();
        }
      });
    });
  }

  stopCron() async {
    timer?.cancel();
    isScanning = false;
    await Globals.locationReference
        .doc(selectedLocation)
        .update({'lastScan': lastScan, 'nextScan': null, 'isScan': false}).then(
            (value) {});
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => getNiceHexArray(val)).join(', ').toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries
        .map((v) => '${v.key}: ${getNiceHexArray(v.value)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  Future startBluetoothScan() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint("Start Scan Error: $e");
    }
  }

  Future<void> getLocationName() async {
    String deviceId = await CommonFunction.getDeviceId();

    await Globals.locationReference
        .where('userId', isEqualTo: Globals.firebaseUser?.uid)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        locationList.clear();
        locationList.addAll(snapshot.docs);

        var selectedData = locationList
            .where((e) => (e?.data()['deviceIds'] != null &&
                e?.data()['deviceIds'].contains(deviceId)))
            .toList();
        if (selectedData.isNotEmpty) {
          selectedLocation = selectedData.first?.id;
        }
      } else {
        selectedLocation = null;
        if (isScanning) {
          stopCron();
        }
      }
    });

    loader = false;
  }

  // Load the JSON file and decode it into a Map
  Future<void> loadJson() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/mac_prefixes.json');
    prefixes = Map<String, String>.from(json.decode(jsonString));
  }

  Future<void> updateLocation() async {
    String deviceId = await CommonFunction.getDeviceId();

    await Globals.locationReference
        .where('userId', isEqualTo: Globals.auth.currentUser?.uid)
        .where('deviceIds', arrayContainsAny: [deviceId])
        .get()
        .then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            await Globals.locationReference.doc(snapshot.docs.first.id).update({
              "deviceIds": FieldValue.arrayRemove([deviceId])
            });
          }
          await Globals.locationReference.doc(selectedLocation).update({
            "deviceIds": FieldValue.arrayUnion([deviceId])
          });
        });
  }

  Future<void> getUserDetails() async {
    await Globals.userReference
        .doc(Globals.firebaseUser?.uid)
        .get()
        .then((value) {
      Map<String, dynamic> userDetails = value.data() as Map<String, dynamic>;

      hideNotification = userDetails['hideNotification'] ?? [];
      fcmToken = userDetails['fcm'];

      debugPrint("Token $fcmToken");

      if (userDetails['notify'] != null) {
        notifyNewDevice = userDetails['notify']['newDevice'];
        notifySuspiciousDevice = userDetails['notify']['suspicious'];
        notifyRemoteDevice = userDetails['notify']['remote'];
      }
      if (userDetails['scanSettings'] != null) {
        btScan = userDetails['scanSettings']['bluetooth'];
        wifiScan = userDetails['scanSettings']['wifi'];
      }
    });
  }

  Future<void> startScanning(BuildContext context) async {
    isScanning = true;

    final bool isConnected =
        await InternetConnectionChecker.instance.hasConnection;
    if (isConnected) {
      await getUserDetails().then((_) async {
        //if (btScan) {
        final bluetoothAdapterState = await FlutterBluePlus.adapterState.first;
        if (await FlutterBluePlus.isSupported &&
            bluetoothAdapterState != BluetoothAdapterState.on) {
          await showBluetoothDialog(context);
        }
        // }
        await startCron();
      });
    } else {
      isScanning = false;
      ToastHelper.showErrorMessage('Device is not connected to the internet');
    }
  }

  Future<void> showBluetoothDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Required'),
        content:
            const Text('Please turn on Bluetooth to continue using this app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FlutterBluePlus.turnOn(); // Request to enable Bluetooth
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Turn On'),
          ),
        ],
      ),
    );
  }

  Future<void> checkIsBluetoothDeviceWithIn3Feet() async {
    List<String> deviceWithIn3Feet = [];
    await Globals.scanReference
        .where('uid', isEqualTo: Globals.firebaseUser?.uid)
        .where('locationId', isEqualTo: selectedLocation)
        .where('bluetoothScan', isNotEqualTo: null)
        .where('dateTime',
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(hours: 2))))
        .orderBy('dateTime', descending: true)
        .get()
        .then((snapshot) async {
      debugPrint("snapshot length ${snapshot.docs.length}");

      if (snapshot.docs.length < 6) {
        return;
      }

      await Future.forEach(snapshot.docs, (doc) async {
        List<String> devices = [];
        await Future.forEach(doc.data()["bluetoothScan"], (dynamic device) {
          double distanceInFeet = calculateDistance(device['rssi'],
              txPower: -59, pathLossExponent: 2.5);
          if (distanceInFeet <= 3.0) {
            devices.add(device['name']);
          }
        });

        if (deviceWithIn3Feet.isEmpty) {
          deviceWithIn3Feet.addAll(devices);
        } else {
          deviceWithIn3Feet.retainWhere((item) => devices.contains(item));
          debugPrint("Updated List deviceWithIn3Feet: $deviceWithIn3Feet");
        }
      });

      deviceWithIn3Feet.retainWhere((item) => hideNotification.contains(item));

      if (deviceWithIn3Feet.isNotEmpty) {
        List<String> btDevices = [];

        await Future.forEach(deviceWithIn3Feet, (macAddress) {
          String macPrefix = macAddress.replaceAll(RegExp(r'[:\-]'), "");
          btDevices.add(
              prefixes?[macPrefix.substring(0, 6).toUpperCase()] ?? macAddress);
        });

        await sendNotification.sendNotification('bt_device', 'Ai Defender',
            "BT $deviceWithIn3Feet in range more than 2 hours", fcmToken);
      }
    });
  }

  double calculateDistance(int rssi,
      {double txPower = -59, double pathLossExponent = 2.0}) {
    // txPower: RSSI at 1 meter (default is -59)
    // pathLossExponent: Environmental factor (default is 2.0 for free space)
    double distanceInMeters =
        pow(10, (txPower - rssi) / (10 * pathLossExponent)).toDouble();
    return distanceInMeters * 3.28084; // Convert meters to feet
  }

  String _getDeviceName(List<int> ports) {
    if (ports[1] != 0 && ports[0] == 0) {
      return ' Suspicious ';
    }

    if (ports[0] != 0 && ports[1] == 0) {
      return ' Remote Accessible ';
    }

    if (ports[0] == 0 && ports[1] == 0) {
      return ' Remote Accessible ';
    }

    return " ";
  }
}
