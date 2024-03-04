class LocalSyncImagesModel {
  final int? id;
  // final String gtin;
  // final String match;
  // final String longitude;
  // final String latitude;
  final String frontImage;
  final String backImage;
  final String leftImage;
  final String rightImage;
  

  LocalSyncImagesModel({
    this.id,
    // required this.match,
    // required this.gtin,
    // required this.longitude,
    // required this.latitude,
    required this.frontImage,
    required this.backImage,
    required this.leftImage,
    required this.rightImage,
  });

  LocalSyncImagesModel.fromMap(
    Map<String, dynamic> res,
  )   : id = res['id'],
        // gtin = res['gtin'],
        // longitude = res['longitude'],
        // latitude = res['latitude'],
        // match = res['match'],
        frontImage=res['frontImage'],
        backImage=res['backImage'],
        leftImage=res['leftImage'],
        rightImage=res['rightImage'];


//to map function will convert the object to a  map

  Map<String, Object?> toMap() {
    return {
      'id': id,
      // 'gtin': gtin,
      // 'match': match,
      // 'longitude': longitude,
      // 'latitude': latitude,
      'frontImage': frontImage,
      'backImage': backImage,
      'leftImage': leftImage,
      'rightImage': rightImage,
    };
  }
}
