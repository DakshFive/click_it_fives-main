class ViewLibraryResponse {
  List<Data>? data;

  ViewLibraryResponse({this.data});

  ViewLibraryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        if(data!=null){
          data!.add(new Data.fromJson(v));
        }

      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? gcp;
  String? gtin;
  String? companyName;
  String? product_name;
  String? imageBack;
  String? imageFront;
  String? imageLeft;
  String? imageRight;
  String? imageTop;
  String? imageBottom;
  String? imageNutritional;
  String? imageIngredients;
  String? status;
  String? imageType;

  Data(
      {this.gcp,
        this.gtin,
        this.companyName,
        this.product_name,
        this.imageBack,
        this.imageFront,
        this.imageLeft,
        this.imageRight,
        this.imageTop,
        this.imageBottom,
        this.imageNutritional,
        this.imageIngredients,
        this.status,
        this.imageType});

  Data.fromJson(Map<String, dynamic> json) {
    gcp = json['gcp'];
    gtin = json['gtin'];
    companyName = json['company_name'];
    product_name = json['product_name'];
    imageBack = json['image_back'];
    imageFront = json['image_front'];
    imageLeft = json['image_left'];
    imageRight = json['image_right'];
    imageTop = json['image_top'];
    imageBottom = json['image_bottom'];
    imageNutritional = json['image_nutritional'];
    imageIngredients = json['image_ingredients'];
    status = json['status'];
    imageType = json['image_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gcp'] = this.gcp;
    data['gtin'] = this.gtin;
    data['company_name'] = this.companyName;
    data['product_name'] = this.product_name;
    data['image_back'] = this.imageBack;
    data['image_front'] = this.imageFront;
    data['image_left'] = this.imageLeft;
    data['image_right'] = this.imageRight;
    data['image_top'] = this.imageTop;
    data['image_bottom'] = this.imageBottom;
    data['image_nutritional'] = this.imageNutritional;
    data['image_ingredients'] = this.imageIngredients;
    data['status'] = this.status;
    data['image_type'] = this.imageType;
    return data;
  }
}