import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullname;
  String? email;
  String? fcm;
  bool? isDeleted;
  Timestamp? createdAt;

  UserModel();

  Map<String, dynamic> toMap(UserModel user) {
    var data = <String, dynamic>{};
    data["fullname"] = user.fullname;
    data["email"] = user.email;
    data["fcm"] = user.fcm;
    data["isDeleted"] = user.isDeleted;
    return data;
  }

  UserModel.fromSnapshot(Map<String, dynamic> data) {
    fullname = data["fullname"];
    email = data["email"];
    fcm = data["fcm"];
    isDeleted = data["isDeleted"];
    createdAt = data["createdAt"];
  }
}
