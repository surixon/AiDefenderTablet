import 'dart:convert';
import 'dart:io';
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
}
