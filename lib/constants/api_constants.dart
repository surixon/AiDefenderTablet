class ApiConstants {

  static const String projectId = "ai-defender-d74f2";
  static const String usersCollection = "users";
  static const String scanCollection = "scan";
  static const String locationsCollection = "locations";

  static const String macLookupBaseUrl = "https://api.maclookup.app/v2/macs";
  static const String baseUrl = "https://api.macvendors.com";
  static const String apiKey =
      "01hrwb6578nmsh4hhb5h1rb18901hrwcfk6eb410wmpw9gjdz4c2khuxvv9gehwz";
  static const String applicationJson = "application/json ";
  static var sendNotification =
      'https://sendnotification-zqwzqggqwq-uc.a.run.app/sendNotification';
  static const String sendEmail =
      "https://sendemail-zqwzqggqwq-uc.a.run.app";


  static const String firebaseBaseUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents";
  static const String locationUrl = "$firebaseBaseUrl/$locationsCollection";
}
