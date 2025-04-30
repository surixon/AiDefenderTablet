import 'dart:convert';
import 'dart:io';
import 'package:ai_defender_tablet/models/user_model.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../locator.dart';
import '../models/mac_address_model.dart';
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
<p><strong>Potential Covert Device found.</strong></p>
<p><strong>None</strong></p>
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

      return UserModel.fromSnapshot(json.decode(response.toString()));
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }

  Future<UserModel?> postScanData(Map<String, Object?> request) async {
    try {
      dio.options.headers["Accept"] = ApiConstants.applicationJson;
      var response = await dio.post(
          "${ApiConstants.firebaseBaseUrl}/${ApiConstants.scanCollection}",
          data: request);

      return UserModel.fromSnapshot(json.decode(response.toString()));
    } on DioException catch (e) {
      if (e.response != null) {
        throw FetchDataException('');
      } else {
        throw const SocketException("Socket Exception");
      }
    }
  }
}
