import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static SharedPreferences? prefs;
  static const themeMode="themeMode";
  static const dark="dark";
  static const light="light";
  static const isLoggedIn='isLoggedIn';
  static const userId='userId';
  static const passwordLessEmail="passwordLessEmail";
  static const fcmToken="fcmToken";
  static const user="user";
  static const oldIpAddresses="oldIpAddresses";

}
