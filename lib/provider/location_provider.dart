import 'dart:io';

import 'package:ai_defender_tablet/provider/base_provider.dart';

import '../enums/viewstate.dart';
import '../helpers/toast_helper.dart';
import '../services/fetch_data_expection.dart';

class LocationProvider extends BaseProvider {
  Future<void> deleteLocation(String? id) async {
    setState(ViewState.busy);
    try {
      api.deleteLocation(id!);
      setState(ViewState.idle);
    } on FetchDataException catch (e) {
      setState(ViewState.idle);
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      setState(ViewState.idle);
      ToastHelper.showErrorMessage('$e');
    }
  }
}
