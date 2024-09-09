class AiDefenderModel {
  String? ID;
  String? BRAND;
  String? CATAGORY;
  String? HTTP_PORT;
  String? IS_SPY_CAMERA;
  String? MAC_BRAND;
  String? VIDEO_PORT;

  AiDefenderModel(this.ID, this.BRAND, this.CATAGORY, this.HTTP_PORT,
      this.IS_SPY_CAMERA, this.MAC_BRAND, this.VIDEO_PORT);

  Map<String, dynamic> toMap(AiDefenderModel model) {
    var data = <String, dynamic>{};
    data["ID"] = model.ID;
    data["BRAND"] = model.BRAND;
    data["CATAGORY"] = model.CATAGORY;
    data["HTTP_PORT"] = model.HTTP_PORT;
    data["IS_SPY_CAMERA"] = model.IS_SPY_CAMERA;
    data["MAC_BRAND"] = model.MAC_BRAND;
    data["VIDEO_PORT"] = model.VIDEO_PORT;
    return data;
  }

  AiDefenderModel.fromSnapshot(Map<String, dynamic> data) {
    ID = data["ID"];
    BRAND = data["BRAND"];
    CATAGORY = data["CATAGORY"];
    HTTP_PORT = data["HTTP_PORT"];
    IS_SPY_CAMERA = data["IS_SPY_CAMERA"];
    MAC_BRAND = data["MAC_BRAND"];
    VIDEO_PORT = data["VIDEO_PORT"];
  }
}
