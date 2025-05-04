import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Globals {
  const Globals._();

  static final auth = FirebaseAuth.instance;

  static final fireStore = FirebaseFirestore.instance;

  static final userReference = fireStore.collection("users");

  static final locationReference = fireStore.collection("locations");

  static final notificationsReference = fireStore.collection("notifications");

  static final deletedUserReference = fireStore.collection("deletedUser");

  static final aiDefenderReference = fireStore.collection("AIDefender");

  static final scanReference = fireStore.collection("scan");

  static User? get firebaseUser => auth.currentUser;

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Map<String, dynamic> getLocationQuery(String locationName) {
    return {
      "structuredQuery": {
        "from": [
          {"collectionId": "locations"}
        ],
        "where": {
          "fieldFilter": {
            "field": {"fieldPath": "locationName"},
            "op": "EQUAL",
            "value": {"stringValue": locationName}
          }
        }
      }
    };
  }

  static Map<String, dynamic> updateLocationQuery(DateTime lastScan) {
    return {
      "fields": {
        "lastScan": {"timestampValue": lastScan.toUtc().toIso8601String()},
        "nextScan": {"nullValue": null},
        "isScan": {"booleanValue": false}
      }
    };
  }

  static Map<String, dynamic> addLocationQuery(
      String userId, String locationName) {
    return {
      "fields": {
        "userId": {"stringValue": userId},
        "locationName": {"stringValue": locationName}
      }
    };
  }
}
