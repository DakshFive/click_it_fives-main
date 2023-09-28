class LoginResponseModel {
  LoginResponseModel({
    required this.companyName,
    required this.companyId,
    required this.source,
    required this.roleId,
    required this.uid,
  });
  late final String companyName;
  late final List<String> companyId;
  late final String source;
  late final int roleId;
  late final String uid;

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    companyName = json['company_name'];
    companyId = List.castFrom<dynamic, String>(json['company_id']);
    source = json['source'];
    roleId = json['role_id'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['company_name'] = companyName;
    _data['company_id'] = companyId;
    _data['source'] = source;
    _data['role_id'] = roleId;
    _data['uid'] = uid;
    return _data;
  }
}

class LoginRequestModel {
  String user_name;
  String password;

  LoginRequestModel(this.user_name, this.password);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'user_name': user_name.trim(),
      'password': password.trim()
    };

    return map;
  }
}
