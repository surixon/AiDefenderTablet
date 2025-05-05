import 'dart:convert';
import 'dart:io';

import 'package:ai_defender_tablet/enums/viewstate.dart';
import 'package:ai_defender_tablet/helpers/toast_helper.dart';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import '../globals.dart';
import '../helpers/shared_pref.dart';
import '../services/fetch_data_expection.dart';

class AddLocationProvider extends BaseProvider {
  Future<void> saveLocation(String location) async {
    setState(ViewState.busy);

    try {
      await api
          .getLocation(Globals.getLocationQuery(location))
          .then((docs) async {
        if (docs.isEmpty) {
          await api.addLocation(Globals.addLocationQuery(
              SharedPref.prefs?.getString(SharedPref.userId) ?? '', location));
          ToastHelper.showMessage('Location added successfully!');
          setState(ViewState.idle);
        } else {
          ToastHelper.showErrorMessage('Location already added!');
          setState(ViewState.idle);
        }
      });
    } on FetchDataException catch (e) {
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      ToastHelper.showErrorMessage('$e');
    }
  }

  Future<void> updateLocation(String? id, String location) async {
    setState(ViewState.busy);

    try {
      api.updateLocationName(id!, Globals.updateLocationNameQuery(location));
      ToastHelper.showMessage('Location updated successfully!');
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
