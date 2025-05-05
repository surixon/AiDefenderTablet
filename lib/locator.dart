import 'package:ai_defender_tablet/notifications/send_notification.dart';
import 'package:ai_defender_tablet/provider/add_location_provider.dart';
import 'package:ai_defender_tablet/provider/dashboard_provider.dart';
import 'package:ai_defender_tablet/provider/download_app_provider.dart';
import 'package:ai_defender_tablet/provider/location_provider.dart';
import 'package:ai_defender_tablet/provider/login_provider.dart';
import 'package:ai_defender_tablet/provider/otp_provider.dart';
import 'package:ai_defender_tablet/provider/settings_provider.dart';
import 'package:ai_defender_tablet/provider/wifi_provider.dart';
import 'package:ai_defender_tablet/services/api_class.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';


GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => SendNotification());
  locator.registerFactory(() => LoginProvider());
  locator.registerFactory(() => WifiProvider());
  locator.registerFactory(() => OtpProvider());
  locator.registerFactory(() => DashboardProvider());
  locator.registerFactory(() => SettingsProvider());
  locator.registerFactory(() => DownloadAppProvider());
  locator.registerFactory(() => AddLocationProvider());
  locator.registerFactory(() => LocationProvider());

  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton<Dio>(() {
    Dio dio = Dio();
    dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        request: true,
        requestHeader: false,
        responseHeader: false));
    return dio;
  });
}
