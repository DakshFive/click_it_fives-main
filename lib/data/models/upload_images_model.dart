class UploadImagesRequestModel {
  UploadImagesRequestModel({
    required this.uid,
    required this.gtin,
    //  required this.companyId,
    required this.imei,
     required this.roleId,
    required this.latitude,
    required this.longitude,
     required this.match,
    required this.source,
    required this.imgBack,
    required this.imgFront,
    required this.imgLeft,
    required this.imgRight,
    required this.imgTop,
    required this.imgBottom,
    required this.imgNutrient,
    required this.imgIngredient,

  });
  late final String uid;
  late final String gtin;
  //  late final List<String?> companyId;
  late final String imei;
  late final String roleId;
  late final String latitude;
  late final String longitude;
  late final String match;
  late final String source;
  late final String? imgBack;
  late final String? imgFront;
  late final String? imgLeft;
  late final String? imgRight;
  late final String? imgTop;
  late final String? imgBottom;
  late final String? imgNutrient;
  late final String? imgIngredient;

  UploadImagesRequestModel.fromJson(Map<String, dynamic> json){
    uid = json['uid'];
    gtin = json['gtin'];
    //  companyId = List.castFrom<dynamic, String>(json['company_id']) ;
    imei = json['imei'];
     roleId = json['role_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
     match = json['match'];
    source = json['source'];
    imgBack = json['img_back'];
    imgFront = json['img_front'];
    imgLeft = json['img_left'];
    imgRight = json['img_right'];
    imgTop = json['img_top'];
    imgBottom = json['img_bottom'];
    imgNutrient = json['img_nutrient'];
    imgIngredient = json['img_ingredient'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['uid'] = uid;
    _data['gtin'] = gtin;
    //  _data['company_id'] = companyId ;
    _data['imei'] = imei;
    _data['role_id'] = roleId;
    _data['latitude'] = latitude;
    _data['longitude'] = longitude;
     _data['match'] = match;
    _data['source'] = source;
    _data['img_back'] = imgBack;
    _data['img_front'] = imgFront;
    _data['img_left'] = imgLeft;
    _data['img_right'] = imgRight;
    _data['img_top'] = imgTop;
    _data['img_bottom'] = imgBottom;
    _data['img_nutrient'] = imgNutrient;
    _data['img_ingredient'] = imgIngredient;
    return _data;
  }
}