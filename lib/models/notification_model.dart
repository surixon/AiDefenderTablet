import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String? userId;
  String? type;
  String? title;
  String? message;
  bool? isRead;
  Timestamp? timestamp;

  NotificationModel(
      {this.id,
      this.userId,
      this.type,
      this.title,
      this.message,
      this.isRead,
      this.timestamp});

  Map<String, dynamic> toMap(NotificationModel user) {
    var data = <String, dynamic>{};
    data["id"] = user.id;
    data["userId"] = user.userId;
    data["type"] = user.type;
    data["title"] = user.title;
    data["message"] = user.message;
    data["isRead"] = user.isRead;
    data["timestamp"] = user.timestamp;
    return data;
  }

  NotificationModel.fromSnapshot(Map<String, dynamic> data) {
    id = data["id"];
    userId = data["userId"];
    type = data["type"];
    title = data["title"];
    message = data["message"];
    timestamp = data["timestamp"];
    isRead = data["isRead"];
  }
}
