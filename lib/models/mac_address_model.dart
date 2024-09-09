import 'dart:convert';

MacAddressModel macAddressModelFromJson(String str) => MacAddressModel.fromJson(json.decode(str));

String macAddressModelToJson(MacAddressModel data) => json.encode(data.toJson());

class MacAddressModel {
  bool? success;
  bool? found;
  String? macPrefix;
  String? company;
  String? address;
  String? country;
  String? blockStart;
  String? blockEnd;
  int? blockSize;
  String? blockType;
  String? updated;
  bool? isRand;
  bool? isPrivate;

  MacAddressModel({
    this.success,
    this.found,
    this.macPrefix,
    this.company,
    this.address,
    this.country,
    this.blockStart,
    this.blockEnd,
    this.blockSize,
    this.blockType,
    this.updated,
    this.isRand,
    this.isPrivate,
  });

  factory MacAddressModel.fromJson(Map<String, dynamic> json) => MacAddressModel(
    success: json["success"],
    found: json["found"],
    macPrefix: json["macPrefix"],
    company: json["company"],
    address: json["address"],
    country: json["country"],
    blockStart: json["blockStart"],
    blockEnd: json["blockEnd"],
    blockSize: json["blockSize"],
    blockType: json["blockType"],
    updated: json["updated"],
    isRand: json["isRand"],
    isPrivate: json["isPrivate"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "found": found,
    "macPrefix": macPrefix,
    "company": company,
    "address": address,
    "country": country,
    "blockStart": blockStart,
    "blockEnd": blockEnd,
    "blockSize": blockSize,
    "blockType": blockType,
    "updated": updated,
    "isRand": isRand,
    "isPrivate": isPrivate,
  };
}