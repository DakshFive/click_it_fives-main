

class Photo {
  int? id;
  
    String? frontImage;
    String? backImage;
    String? leftImage;
    String?rightImage;

  Photo({this.id,  
        this.frontImage,
      this.backImage,
      this.leftImage,
      this.rightImage,
      
      }
  
  );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      
      'frontImage': frontImage,
      'backImage': backImage,
      'leftImage': leftImage,
      'rightImage': rightImage,
      
    };
    return map;
  }

  Photo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    
    frontImage = map['frontImage'];
    backImage = map['backImage'];
    leftImage = map['leftImage'];
    rightImage = map['rightImage'];
  }


}