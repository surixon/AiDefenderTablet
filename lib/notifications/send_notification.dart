import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/string_constants.dart';
import '../globals.dart';
import '../locator.dart';
import '../models/notification_model.dart';

class SendNotification {
  Dio dio = locator<Dio>();

  Future<void> sendNotification(
    String type,
    String title,
    String message,
    String fcmToken,
  ) async {
   /* var userId = Globals.firebaseUser?.uid;
    var id = Globals.notificationsReference
        .doc(userId)
        .collection('notification')
        .doc()
        .id;*/
    //addNotificationInDB(id,userId, type, title, message);
    try {
      Map<String, dynamic> data = {
        "title": title,
        "body": message,
        "data": {
         /* 'id': id,
          'userId': userId,*/
          'title': title,
          'body': message,
          'type': type,
        },
        "android": {
          "priority": "HIGH",
          "notification": {
            "default_sound": true,
            "default_vibrate_timings": true,
            "default_light_settings": true,
            "notification_priority": "PRIORITY_HIGH"
          }
        },
        "apns": {
          "payload": {
            "aps": {
              "category": "NEW_MESSAGE_CATEGORY",
              'title': title,
              'body': message,
              "sound": "default"
            }
          }
        },
        "token": fcmToken
      };

      debugPrint("Request  ${data}");

      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.post(ApiConstants.sendNotification, data: data);
      debugPrint("Response Status Code ${response.statusCode}");
    } on DioException catch (e) {
      debugPrint("Error Status Code ${e.response?.statusCode}");
    }
  }

  /* Future<void> sendNotification(
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
  }*/

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
