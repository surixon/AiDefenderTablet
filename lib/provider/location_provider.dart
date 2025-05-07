import 'dart:io';
import 'package:ai_defender_tablet/provider/base_provider.dart';
import '../enums/viewstate.dart';
import '../globals.dart';
import '../helpers/shared_pref.dart';
import '../helpers/toast_helper.dart';
import '../models/location.dart';
import '../services/fetch_data_expection.dart';

class LocationProvider extends BaseProvider {
  bool _loader = false;

  bool get loader => _loader;

  set loader(bool value) {
    _loader = value;
    customNotify();
  }

  List<Location> locationList = [];

  Future<void> deleteLocation(String? id) async {
    setState(ViewState.busy);
    try {
      await api.deleteLocation(id!).then((v) async {
        await getLocationList();
      });
      setState(ViewState.idle);
    } on FetchDataException catch (e) {
      setState(ViewState.idle);
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      setState(ViewState.idle);
      ToastHelper.showErrorMessage('$e');
    }
  }

  Future<void> getLocationList() async {
    try {
      loader = true;
      var data = await api.getLocation(Globals.getLocationByUserIdQuery(
          SharedPref.prefs?.getString(SharedPref.userId) ?? ''));

      if (data.isNotEmpty) {
        locationList = parseLocations(data);
      }
      loader = false;
    } on FetchDataException catch (e) {
      loader = false;
      ToastHelper.showErrorMessage('$e');
    } on SocketException catch (e) {
      loader = false;
      ToastHelper.showErrorMessage('$e');
    }
  }
}
