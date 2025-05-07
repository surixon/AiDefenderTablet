

List<Location> parseLocations(List<dynamic> data) {
  return data.map((e) => Location.fromMap(e as Map<String, dynamic>)).toList();
}

class Location {
  final String id;
  final String userId;
  final String locationName;
  final String createTime;
  final String updateTime;
  final List<dynamic>? deviceIds;

  Location({
    required this.id,
    required this.userId,
    required this.locationName,
    required this.createTime,
    required this.updateTime,
    required this.deviceIds,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      userId: map['userId'],
      locationName: map['locationName'],
      createTime: map['createTime'],
      updateTime: map['updateTime'],
      deviceIds: map['deviceIds'],
    );
  }
}
