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
    try {
      Map<String, dynamic> data = {
        "title": title,
        "body": message,
        "data": {
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

      debugPrint("Request  $data");

      dio.options.headers['content-Type'] = 'application/json';
      var response = await dio.post(ApiConstants.sendNotification, data: data);
      debugPrint("Response Status Code ${response.statusCode}");
    } on DioException catch (e) {
      debugPrint("Error Status Code ${e.response?.statusCode}");
    }
  }
}
