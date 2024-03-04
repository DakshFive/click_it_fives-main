class GetImagesResponseModel {
  GetImagesResponseModel({
    required this.imageFront,
    required this.imageBack,
    required this.imageLeft,
    required this.imageRight,
  });
  late final String imageFront;
  late final String imageBack;
  late final String imageLeft;
  late final String imageRight;

  GetImagesResponseModel.fromJson(Map<String, dynamic> json) {
    imageFront = json['image_front'];
    imageBack = json['image_back'];
    imageLeft = json['image_left'];
    imageRight = json['image_right'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image_front'] = imageFront;
    _data['image_back'] = imageBack;
    _data['image_left'] = imageLeft;
    _data['image_right'] = imageRight;
    return _data;
  }
}

class GetImagesRequestModel {
  GetImagesRequestModel({
    required this.gtin,
    // this.companyId,
    // this.imei,
  });
  late final String gtin;
  late final List<String> companyId;
  late final String imei;

  GetImagesRequestModel.fromJson(Map<String, dynamic> json) {
    gtin = json['gtin'];
    companyId = List.castFrom<dynamic, String>(json['company_id']);
    imei = json['imei'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['gtin'] = gtin;
    // _data['company_id'] = companyId;
    // _data['imei'] = imei;
    return _data;
  }
}
