
import 'dart:convert';

EditImagesRequestModel datamodelFromJson(String str)=>EditImagesRequestModel.fromJson(json.decode(str));
String datamodeltoJson(EditImagesRequestModel data) =>jsonEncode(data.toJson());

class EditImagesRequestModel {

  EditImagesRequestModel(
      {required this.editFrontImage,
      required this.editBackImage,
      required this.editRightImage,
      required this.editLeftImage});
  late final String? editRightImage;
  late final String? editLeftImage;
  late final String? editFrontImage;
  late final String? editBackImage;

  EditImagesRequestModel.fromJson(Map<String, dynamic> json) {
    editFrontImage = json['editFrontImage'];
    editBackImage = json['editBackImage'];
    editRightImage = json['editRightImage'];

    editLeftImage = json['editLeftImage'];
  }

  Map<String, dynamic> toJson() {
    final _editedImages = <String, dynamic>{};
    _editedImages['editFrontImage'] = editFrontImage;
    _editedImages['editBackImage'] = editBackImage;
    _editedImages['editRightImage'] = editRightImage;
    _editedImages['editLeftImage'] = editLeftImage;
    return _editedImages;
  }
}
