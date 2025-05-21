import 'dart:convert';
import 'dart:io';
import 'package:ai_defender_tablet/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../constants/api_constants.dart';
import '../locator.dart';
import '../models/mac_address_model.dart';
import '../models/scan_model.dart';
import 'fetch_data_expection.dart';

class Api {
  Dio dio = locator<Dio>();

  Future<String> getMacAddress(
    String macAddress,
  ) async {
    try {
      //dio.options.headers["Accept"] = ApiConstants.applicationJson;
      var response = await dio.get(
        "${ApiConstants.baseUrl}/$macAddress", /*queryParameters: {
        "apiKey": ApiConstants.apiKey,
      }*/
      );
      // return MacAddressModel.fromJson(json.decode(response.toString()));
      if (response.statusCode == 200) {
        return response.toString();
      } else if (response.statusCode == 404) {
        return '';
      } else {
        return '';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<MacAddressModel?> getDeviceName(
    String macAddress,
  ) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      var response = await dio.get(
          "${ApiConstants.macLookupBaseUrl}/$macAddress",
          queryParameters: {
            "apiKey": ApiConstants.apiKey,
          });

      if (response.statusCode == 200) {
        return MacAddressModel.fromJson(json.decode(response.toString()));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<bool> sendEmail(String emailId, List<String> deviceWithIn3Feet) async {
    try {
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;

      final htmlContent = '''
<ul>
  ${deviceWithIn3Feet.map((device) => '<li><strong>Device:</strong> $device</li>').join()}
</ul>
''';

      var response = await dio.post(ApiConstants.sendEmail, data: {
        'to': emailId,
        'subject': 'Alert from AI Defender',
        'html': '''
<p>No-Reply</p>
<p><strong>This is an alert from your AI Defender Covert Device Firewall.</strong></p>
<p><strong>Lingering Bluetooth Device found.</strong> The following has been detected for longer than your time-on-site setting:</p>
$htmlContent
<p>If you see a known safe device, you can manage your alerts, view log files, and remove any device from your alerts list using the <strong>AI Defender Mobile App</strong>.</p>
'''
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<UserModel?> getUserData(
    String id,
  ) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      var response = await dio.get(
          "${ApiConstants.firebaseBaseUrl}/${ApiConstants.usersCollection}/$id");

      return UserModel.fromFirestore(json.decode(response.toString()));
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future< List<ScanModel>> getScanData(Map<String, dynamic> body) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      var response = await dio.post("${ApiConstants.firebaseBaseUrl}:runQuery",
      data: body);
      return  parseScanDocuments(json.encode(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<List<dynamic>> getLocation(Map<String, dynamic> body) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      var response = await dio.post("${ApiConstants.firebaseBaseUrl}:runQuery",
          data: body);
      return parseLocationDocuments(json.encode(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<void> removeDeviceId(String docId, String deviceId) async {
    try {
      var data = {
        "writes": [
          {
            "transform": {
              "document":
                  "projects/${ApiConstants.projectId}/databases/(default)/documents/locations/$docId",
              "fieldTransforms": [
                {
                  "fieldPath": "deviceIds",
                  "removeAllFromArray": {
                    "values": [
                      {"stringValue": deviceId}
                    ]
                  }
                }
              ]
            }
          }
        ]
      };
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      await dio.post("${ApiConstants.firebaseBaseUrl}:commit", data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<void> addDeviceId(String docId, String deviceId) async {
    try {
      var data = {
        "fields": {
          "deviceIds": {
            "arrayValue": {
              "values": [
                {"stringValue": deviceId}
              ]
            }
          }
        }
      };
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      await dio.patch(
          "${ApiConstants.locationUrl}/$docId?updateMask.fieldPaths=deviceIds",
          data: data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<Map<String, dynamic>> addLocation(Map<String, dynamic> body) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      var response = await dio.post(ApiConstants.locationUrl, data: body);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<void> updateLocation(
      String locationId, Map<String, dynamic> request) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      var response = await dio.patch(
          "${ApiConstants.locationUrl}/$locationId?updateMask.fieldPaths=lastScan&updateMask.fieldPaths=isScan&updateMask.fieldPaths=nextScan",
          data: request);
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<void> updateLocationName(
      String locationId, Map<String, dynamic> request) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      await dio.patch(
          "${ApiConstants.locationUrl}/$locationId?updateMask.fieldPaths=locationName",
          data: request);
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<void> deleteLocation(String locationId) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      dio.options.headers["Content-Type"] = ApiConstants.applicationJson;
      await dio.delete(
        "${ApiConstants.locationUrl}/$locationId",
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<void> postScanData(Map<String, Object?> request) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      await dio.post(
          "${ApiConstants.firebaseBaseUrl}/${ApiConstants.scanCollection}",
          data: request);
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  List<Map<String, dynamic>> parseLocationDocuments(String responseBody) {
    final List<dynamic> jsonList = json.decode(responseBody);

    return jsonList
        .map<Map<String, dynamic>>((entry) {
          final doc = entry['document'];
          if (doc == null) return {}; // Skip if document is missing

          final fields = doc['fields'];
          if (fields == null) return {}; // Skip if fields are missing

          return {
            'id': doc['name']?.split('/')?.last,
            'userId': fields['userId']?['stringValue'],
            'locationName': fields['locationName']?['stringValue'],
            'createTime': doc['createTime'],
            'updateTime': doc['updateTime'],
          };
        })
        .where((map) => map.isNotEmpty) // Filter out empty maps
        .toList();
  }

  List<ScanModel> parseScanDocuments(String responseBody) {
    final List<dynamic> docs = json.decode(responseBody);
    // Check if the documents list is empty or contains invalid data
    if (docs.isEmpty) {
      print('No scan documents found.');
      return [];
    }

    return docs
        .where((e) => e['document'] != null) // Only process documents with valid data
        .map((e) => ScanModel.fromFirestore(e['document']))
        .toList();
  }
}
