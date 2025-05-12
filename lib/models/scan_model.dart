class Scan {
  final String ip;
  final String macAddress;
  final List<int> ports;
  final String? brand;

  Scan({
    required this.ip,
    required this.macAddress,
    required this.ports,
    this.brand,
  });

  factory Scan.fromMap(Map<String, dynamic> data) {
    final portsRaw = data['ports']['arrayValue']['values'] as List<dynamic>? ?? [];
    final ports = portsRaw.map((e) => int.tryParse(e['integerValue']) ?? 0).toList();

    return Scan(
      ip: data['ip']['stringValue'] ?? '',
      macAddress: data['macAddress']['stringValue'] ?? '',
      ports: ports,
      brand: data['brand']?['stringValue'], // nullable
    );
  }
}

class ScanModel {
  final String id;
  final String uid;
  final DateTime dateTime;
  final List<Scan> scan;
  final List<BluetoothScan> bluetoothScan;

  ScanModel({
    required this.id,
    required this.uid,
    required this.dateTime,
    required this.scan,
    required this.bluetoothScan,
  });

  factory ScanModel.fromFirestore(Map<String, dynamic> document) {
    final fields = document['fields'] as Map<String, dynamic>;

    final scanList = (fields['scan']['arrayValue']['values'] as List<dynamic>? ?? [])
        .map((e) => Scan.fromMap(e['mapValue']['fields'] as Map<String, dynamic>))
        .toList();

    final bluetoothList =
    (fields['bluetoothScan']?['arrayValue']?['values'] as List<dynamic>? ?? [])
        .map((e) => BluetoothScan.fromMap(e['mapValue']['fields'] as Map<String, dynamic>))
        .toList();

    return ScanModel(
      id: document['name'].split('/').last,
      uid: fields['uid']['stringValue'] ?? '',
      dateTime: DateTime.parse(fields['dateTime']['stringValue']),
      scan: scanList,
      bluetoothScan: bluetoothList,
    );
  }
}

class BluetoothScan {
  final String name;
  final String bluetoothName;
  final String device;
  final String manufacturer;
  final String appearance;
  final int? rssi;
  final int? txPowerLevel;

  BluetoothScan({
    required this.name,
    required this.bluetoothName,
    required this.device,
    required this.manufacturer,
    required this.appearance,
    this.rssi,
    this.txPowerLevel,
  });

  factory BluetoothScan.fromMap(Map<String, dynamic> map) {
    return BluetoothScan(
      name: map['name']?['stringValue'] ?? '',
      bluetoothName: map['bluetoothName']?['stringValue'] ?? '',
      device: map['device']?['stringValue'] ?? '',
      manufacturer: map['manufacturer']?['stringValue'] ?? '',
      appearance: map['appearance']?['stringValue'] ?? '',
      rssi: map['rssi']?['integerValue'] != null
          ? int.tryParse(map['rssi']['integerValue'].toString())
          : null,
      txPowerLevel: map['txPowerLevel']?['integerValue'] != null
          ? int.tryParse(map['txPowerLevel']['integerValue'].toString())
          : null,
    );
  }
}

