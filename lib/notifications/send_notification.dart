import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../constants/string_constants.dart';
import '../globals.dart';
import '../models/notification_model.dart';

class SendNotification {
  Future<void> sendNotification(
      String type,
      String title,
      String message,
      String fcmToken,
      ) async {

    var userId = Globals.firebaseUser?.uid;
    var id = Globals.notificationsReference
        .doc(userId)
        .collection('notification')
        .doc()
        .id;

    addNotificationInDB(id,userId, type, title, message);

    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$kServerKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title ,
              'body': message,
              'sound': 'default'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': id,
              'userId': userId,
              'title': title,
              'body': message,
              'type': type,
              'status': 'done'
            },
            "to": fcmToken,
          },
        ),
      );
      debugPrint(response.body);
    } catch (e) {
      debugPrint("error push notification");
    }
  }

  Future<void> addNotificationInDB(
    String? id,
    String? userID,
    String type,
    String title,
    String message,
  ) async {
    NotificationModel notificationModel = NotificationModel();
    notificationModel.id = id;
    notificationModel.userId = userID;
    notificationModel.title = title;
    notificationModel.message = message;
    notificationModel.type = type;
    notificationModel.isRead = false;
    notificationModel.timestamp = Timestamp.now();
    await Globals.notificationsReference
        .doc(userID)
        .collection('notification')
        .doc(id)
        .set(notificationModel.toMap(notificationModel));
  }
}
