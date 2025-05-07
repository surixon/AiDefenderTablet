import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'constants/api_constants.dart';
import 'helpers/shared_pref.dart';

class Globals {
  const Globals._();

  static final auth = FirebaseAuth.instance;

  static final fireStore = FirebaseFirestore.instance;

  static final userReference = fireStore.collection("users");

  static final locationReference = fireStore.collection("locations");

  static final notificationsReference = fireStore.collection("notifications");

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

  static Map<String, dynamic> getLocationByUserIdQuery(String userId) {
    return {
      "structuredQuery": {
        "from": [{ "collectionId": "locations"}],
        "where": {
          "fieldFilter": {
            "field": { "fieldPath": "userId"},
            "op": "EQUAL",
            "value": { "stringValue": userId}
          }
        }
      }
    }
    ;
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

  static Map<String, dynamic> updateLastAndNextScan(DateTime lastScan,
      DateTime nextScan) {
    return {
      "fields": {
        "lastScan": {"timestampValue": lastScan.toUtc().toIso8601String()},
        "nextScan": {"timestampValue": nextScan.toUtc().toIso8601String()},
        "isScan": {"booleanValue": true}
      }
    };
  }

  static Map<String, dynamic> updateLocationNameQuery(String locationName) {
    return {
      "fields": {
        "locationName": {"stringValue": locationName}
      }
    };
  }

  static Map<String, dynamic> getLocationWhereDeviceIds(String userId,
      String deviceId) {
    return {
      "structuredQuery": {
        "from": [
          {"collectionId": "locations"}
        ],
        "where": {
          "compositeFilter": {
            "op": "AND",
            "filters": [
              {
                "fieldFilter": {
                  "field": {"fieldPath": "userId"},
                  "op": "EQUAL",
                  "value": {"stringValue": userId}
                }
              },
              {
                "fieldFilter": {
                  "field": {"fieldPath": "deviceIds"},
                  "op": "ARRAY_CONTAINS_ANY",
                  "value": {
                    "arrayValue": {
                      "values": [
                        {"stringValue": deviceId}
                      ]
                    }
                  }
                }
              }
            ]
          }
        }
      }
    };
  }

  static Map<String, dynamic> addLocationQuery(String userId,
      String locationName) {
    return {
      "fields": {
        "userId": {"stringValue": userId},
        "locationName": {"stringValue": locationName}
      }
    };
  }

  static Map<String, dynamic> getActiveBluetoothDevices(
      String selectedLocation) {
    return {
      "structuredQuery": {
        "from": [
          {"collectionId": ApiConstants.scanCollection}
        ],
        "where": {
          "compositeFilter": {
            "op": "AND",
            "filters": [
              {
                "fieldFilter": {
                  "field": {"fieldPath": "uid"},
                  "op": "EQUAL",
                  "value": {
                    "stringValue":
                    SharedPref.prefs?.getString(SharedPref.userId)
                  }
                }
              },
              {
                "fieldFilter": {
                  "field": {"fieldPath": "locationId"},
                  "op": "EQUAL",
                  "value": {"stringValue": selectedLocation}
                }
              },
              {
                "fieldFilter": {
                  "field": {"fieldPath": "bluetoothScan"},
                  "op": "IS_NOT_NULL"
                }
              },
              {
                "fieldFilter": {
                  "field": {"fieldPath": "dateTime"},
                  "op": "GREATER_THAN",
                  "value": {
                    "timestampValue": Timestamp.fromDate(
                        DateTime.now().subtract(const Duration(hours: 2)))
                  }
                }
              }
            ]
          }
        },
        "orderBy": [
          {
            "field": {"fieldPath": "dateTime"},
            "direction": "DESCENDING"
          }
        ]
      }
    };
  }
}

