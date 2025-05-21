import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/common_function.dart';
import 'package:ai_defender_tablet/helpers/shared_pref.dart';
import 'package:ai_defender_tablet/helpers/toast_helper.dart';
import 'package:ai_defender_tablet/models/ai_defender_model.dart';
import 'package:ai_defender_tablet/models/scan_model.dart';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../globals.dart';
import 'package:network_tools/network_tools.dart';
import '../locator.dart';
import '../models/device_model.dart';
import '../models/location.dart';
import '../notifications/send_notification.dart';
import '../services/fetch_data_expection.dart';

class DashboardProvider extends BaseProvider {
  bool isBluetoothSupported = false;

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
  List<ScanResult> btScanResults = [];

  String fcmToken = '';
  String emailId = '';
  bool notifyNewDevice = false;
  bool notifySuspiciousDevice = false;
  bool notifyRemoteDevice = false;
  bool emailNotification = false;
  bool btScan = true;
  bool wifiScan = true;

  List<Location> locationList = [];

  String? selectedLocation;

  bool _isScanning = false;

  bool get isScanning => _isScanning;

  set isScanning(bool value) {
    _isScanning = value;
    customNotify();
  }

  Future<void> startWifiScan() async {
    setState(ViewState.busy);
    lastScan = DateTime.now();
    nextScan = lastScan?.add(const Duration(hours: 1));

    await api.updateLocation(
        selectedLocation!, Globals.updateLastAndNextScan(lastScan!, nextScan!));

    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip == null) {
      debugPrint('Could not get WiFi IP');
      return;
    }

    final scanner = LanScanner(debugLogging: true);
    final hosts = await scanner.quickIcmpScanAsync(
      ipToCSubnet(ip),
    );
    _devices.clear();
    _hosts.clear();
    _hosts.addAll(hosts);

    // Parse ARP table into a map of IP -> MAC
    final macMap = <String, String>{};

    if (Platform.isLinux) {
      // Fetch ARP table
      final arpResult = await Process.run('arp', ['-a']);
      final arpOutput = arpResult.stdout as String;

      await Future.forEach(arpOutput.split('\n'), (line) {
        final match = RegExp(r'\((.*?)\) at ([0-9a-f:]+)').firstMatch(line);
        if (match != null) {
          macMap[match.group(1)!] = match.group(2)!;
        }
      });
    }

    await Future.forEach(_hosts, (element) async {
      //Match scanned hosts with MAC addresses
      final String mac = macMap[element.internetAddress.address] ?? '';

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
          notifyRemoteDevice) {
        await sendNotification.sendNotification(
            'remote_device',
            'Ai Defender',
            "Remote Accessible Device Found (${element.internetAddress.address})",
            fcmToken);
      }

      if (!hideNotification.contains(element.internetAddress.address) &&
          !isOpen554 &&
          !isOpen80 &&
          notifySuspiciousDevice) {
        await sendNotification.sendNotification(
            'other_device',
            'Ai Defender',
            "Other Device Found (${element.internetAddress.address})",
            fcmToken);
      }

      List<int> ports = [isOpen80 ? 80 : 0, isOpen554 ? 554 : 0];
      _devices.add(DeviceModel(element.internetAddress.address, ports, mac));
    });

    setState(ViewState.idle);
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

    await Future.forEach(btScanResults, (bluetooth) async {
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
      'dateTime': DateTime.now().toUtc().toIso8601String(),
      'uid': SharedPref.prefs?.getString(SharedPref.userId),
      'scan': scanList,
      'locationId': selectedLocation,
      'bluetoothScan': bluetoothScanList,
      'dateOnly': CommonFunction.getDateFromTimeStamp(
          DateTime.now().toUtc(), 'yyyyMMdd')
    };

    final Map<String, dynamic> fireStorePayload = {
      'fields':
          request.map((key, value) => MapEntry(key, toFireStoreFields(value))),
    };

    await api.postScanData(fireStorePayload);
  }

  startCron() async {
    var bluetoothAdapterState = await FlutterBluePlus.adapterState.first;
    if (btScan &&
        !wifiScan &&
        bluetoothAdapterState == BluetoothAdapterState.on &&
        isBluetoothSupported) {
      await startBluetoothScan().then((_) async {
        await uploadData();
      });
    }

    if (!btScan && wifiScan) {
      btScanResults.clear();
      await startWifiScan().then((value) async {
        await uploadData();
      });
    }

    if (btScan && wifiScan) {
      if (isBluetoothSupported) {
        await startBluetoothScan().then((_) async {
          await startWifiScan().then((_) async {
            await uploadData();
          });
        });
      } else {
        btScanResults.clear();
        await startWifiScan().then((_) async {
          await uploadData();
        });
      }
    }

    if (btScan) {
      checkLast2HoursActiveDevice();
    }

    timer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await getUserDetails().then((_) async {
        if (btScan &&
            !wifiScan &&
            bluetoothAdapterState == BluetoothAdapterState.on &&
            isBluetoothSupported) {
          await startBluetoothScan().then((_) async {
            await uploadData();
          });
        }

        if (!btScan && wifiScan) {
          btScanResults.clear();
          await startWifiScan().then((value) async {
            await uploadData();
          });
        }

        if (btScan && wifiScan) {
          if (isBluetoothSupported) {
            await startBluetoothScan().then((_) async {
              await startWifiScan().then((_) async {
                await uploadData();
              });
            });
          } else {
            btScanResults.clear();
            await startWifiScan().then((_) async {
              await uploadData();
            });
          }
        }

        if (btScan) {
          checkLast2HoursActiveDevice();
        }
      });
    });
  }

  stopCron() async {
    timer?.cancel();
    isScanning = false;
    try {
      api.updateLocation(
          selectedLocation!, Globals.updateLocationQuery(lastScan!));
    } on FetchDataException catch (e) {
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      ToastHelper.showErrorMessage('$e');
    }
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
      final subscription = FlutterBluePlus.scanResults.listen((scanResult) {
        for (var result in scanResult) {
          // Avoid duplicates
          if (!btScanResults.any(
              (r) => r.device.remoteId.str == result.device.remoteId.str)) {
            btScanResults.add(result);
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 5));
      // Stop scanning
      await FlutterBluePlus.stopScan();
      // Cancel the subscription
      await subscription.cancel();
    } catch (e) {
      debugPrint("Start Scan Error: $e");
    }
  }

  Future<void> getLocationName() async {
    String deviceId = await CommonFunction.getDeviceId();

    try {
      var data = await api.getLocation(Globals.getLocationByUserIdQuery(
          SharedPref.prefs?.getString(SharedPref.userId) ?? ''));

      if (data.isNotEmpty) {
        List<Location> list = parseLocations(data);
        locationList.clear();
        locationList.addAll(list);

        var selectedData = locationList
            .where(
                (e) => (e.deviceIds != null && e.deviceIds!.contains(deviceId)))
            .toList();
        if (selectedData.isNotEmpty) {
          selectedLocation = selectedData.first.id;
        }
      } else {
        selectedLocation = null;
        if (isScanning) {
          stopCron();
        }
      }
    } on FetchDataException catch (e) {
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      ToastHelper.showErrorMessage('$e');
    }

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
    try {
      await api
          .getLocation(Globals.getLocationWhereDeviceIds(
              SharedPref.prefs?.getString(SharedPref.userId) ?? '', deviceId))
          .then((value) async {
        if (value.isNotEmpty) {
          final String? docId = value[0]['id'];
          if (docId != null) {
            await api.removeDeviceId(docId, deviceId);
          }
        }
        await api.addDeviceId(selectedLocation!, deviceId);
      });
    } on FetchDataException catch (e) {
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      ToastHelper.showErrorMessage('$e');
    }
  }

  Future<void> getUserDetails() async {
    try {
      await api
          .getUserData(SharedPref.prefs?.getString(SharedPref.userId) ?? '')
          .then((value) async {
        if (value != null) {
          hideNotification = value.hideNotification ?? [];
          fcmToken = value.fcmToken ?? '';
          emailId = value.email ?? '';

          notifyNewDevice = value.notifyNewDevice ?? false;
          notifySuspiciousDevice = value.notifySuspiciousDevice ?? false;
          notifyRemoteDevice = value.notifyRemoteDevice ?? false;
          emailNotification = value.emailNotification ?? false;

          btScan = value.scanBluetooth ?? false;
          wifiScan = value.scanWifi ?? false;
        }
      });
    } on FetchDataException catch (e) {
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      ToastHelper.showErrorMessage('$e');
    }
  }

  Future<void> startScanning(BuildContext context) async {
    isScanning = true;

    final bool isConnected =
        await InternetConnectionChecker.instance.hasConnection;
    if (isConnected) {
      await getUserDetails().then((_) async {
        final bluetoothAdapterState = await FlutterBluePlus.adapterState.first;
        if (isBluetoothSupported &&
            bluetoothAdapterState != BluetoothAdapterState.on) {
          await showBluetoothDialog(context);
        }
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

  Future<void> checkLast2HoursActiveDevice() async {
    List<String> activeDevice = [];

    var data = await api
        .getScanData(Globals.getActiveBluetoothDevices(selectedLocation ?? ''));
    var filterList = data.where((e) => e.bluetoothScan.isNotEmpty);

    if (filterList.length < 2) {
      return;
    }

    await Future.forEach(filterList, (doc) async {
      List<String> devices = [];
      await Future.forEach(doc.bluetoothScan, (BluetoothScan device) {
        devices.add(device.name);
      });

      activeDevice.addAll(devices);

      if (activeDevice.isEmpty) {
        activeDevice.addAll(devices);
      } else {
        //The condition is: devices.contains(item) → meaning only keep item if it exists in the devices list.
        activeDevice.retainWhere((item) => devices.contains(item));
      }
    });

    List<String> uniqueDevices = activeDevice.toSet().toList();
    uniqueDevices.retainWhere((item) => !hideNotification.contains(item));

    if (uniqueDevices.isNotEmpty) {
      List<String> btDevices = [];
      await Future.forEach(uniqueDevices, (macAddress) {
        String macPrefix = macAddress.replaceAll(RegExp(r'[:\-]'), "");
        btDevices.add(
            prefixes?[macPrefix.substring(0, 6).toUpperCase()] ?? macAddress);
      });
      await sendNotification.sendNotification('bt_device', 'Ai Defender',
          "BT $uniqueDevices in range more than 2 hours", fcmToken);
      await sendEmail(uniqueDevices);
    }
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

  Future<void> sendEmail(List<String> deviceWithIn3Feet) async {
    if (emailId.isEmpty) {
      return;
    }
    try {
      await api.sendEmail(emailId, deviceWithIn3Feet);
    } on FetchDataException catch (e) {
      debugPrint("Error $e");
    } on SocketException catch (e) {
      debugPrint("Error $e");
    }
  }

  Map<String, dynamic> toFireStoreFields(dynamic data) {
    if (data == null) {
      return {'nullValue': null};
    } else if (data is String) {
      return {'stringValue': data};
    } else if (data is int) {
      return {'integerValue': data.toString()};
    } else if (data is double) {
      return {'doubleValue': data};
    } else if (data is bool) {
      return {'booleanValue': data};
    } else if (data is DateTime) {
      return {'stringValue': data.toUtc().toIso8601String()};
    } else if (data is List) {
      return {
        'arrayValue': {
          'values': data.map((item) => toFireStoreFields(item)).toList(),
        }
      };
    } else if (data is Map<String, dynamic>) {
      return {
        'mapValue': {
          'fields': data.map(
            (key, value) => MapEntry(key, toFireStoreFields(value)),
          )
        }
      };
    } else {
      throw UnsupportedError('Unsupported data type: ${data.runtimeType}');
    }
  }

  Future<void> checkIsBluetoothSupported() async {
    isBluetoothSupported = await FlutterBluePlus.isSupported;
  }
}
