class UserModel {
  final String? fullName;
  final String? email;
  final String? fcmToken;
  final String? wifiName;
  final String? location;
  final bool? isScan;
  final DateTime? lastScan;
  final DateTime? nextScan;
  final List<dynamic>? hideNotification;

  final bool? notifyNewDevice;
  final bool? notifySuspiciousDevice;
  final bool? notifyRemoteDevice;
  final bool? emailNotification;
  final bool? supportNotification;

  final bool? scanBluetooth;
  final bool? scanWifi;
  final bool? scanLan;

  UserModel({
    required this.fullName,
    required this.email,
    required this.fcmToken,
    required this.wifiName,
    required this.location,
    required this.isScan,
    this.lastScan,
    this.nextScan,
    required this.hideNotification,
    required this.notifyNewDevice,
    required this.notifySuspiciousDevice,
    required this.notifyRemoteDevice,
    required this.emailNotification,
    required this.supportNotification,
    required this.scanBluetooth,
    required this.scanWifi,
    required this.scanLan,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>;

    Map<String, dynamic> getMapField(String key) =>
        fields[key]?['mapValue']?['fields'] ?? {};

    List<String> parseStringArray(Map<String, dynamic> arrayValue) {
      final values = arrayValue['arrayValue']?['values'] ?? [];
      return List<String>.from(
        values.map((item) => item['stringValue'] as String),
      );
    }

    return UserModel(
      fullName: fields['fullname']?['stringValue'] ?? '',
      email: fields['email']?['stringValue'] ?? '',
      fcmToken: fields['fcm']?['stringValue'] ?? '',
      wifiName: fields['wifiName']?['stringValue']?.replaceAll('"', '') ?? '',
      location: fields['location']?['stringValue'] ?? '',
      isScan: fields['isScan']?['booleanValue'] ?? false,
      lastScan: DateTime.tryParse(fields['lastScan']?['timestampValue'] ?? ''),
      nextScan: DateTime.tryParse(fields['nextScan']?['timestampValue'] ?? ''),
      hideNotification: parseStringArray(fields['hideNotification'] ?? {}),
      notifyNewDevice:
      getMapField('notify')['newDevice']?['booleanValue'] ?? false,
      notifySuspiciousDevice:
      getMapField('notify')['suspicious']?['booleanValue'] ?? false,
      notifyRemoteDevice:
      getMapField('notify')['remote']?['booleanValue'] ?? false,
      emailNotification:
      getMapField('notify')['emailNotification']?['booleanValue'] ?? false,
      supportNotification:
      getMapField('notify')['supportNotification']?['booleanValue'] ?? false,
      scanBluetooth:
      getMapField('scanSettings')['bluetooth']?['booleanValue'] ?? false,
      scanWifi:
      getMapField('scanSettings')['wifi']?['booleanValue'] ?? false,
      scanLan: getMapField('scanSettings')['lan']?['booleanValue'] ?? false,
    );
  }
}
