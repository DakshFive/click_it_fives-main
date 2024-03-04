/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class Filename {
    String? front;

    Filename({this.front}); 

    Filename.fromJson(Map<String, dynamic> json) {
        front = json['front'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['front'] = front;
        return data;
    }
}

class Root {
    Filename? filename;
    String? fulltext;
    SanityCheck? sanitycheck;
    Time? time;

    Root({this.filename, this.fulltext, this.sanitycheck, this.time}); 

    Root.fromJson(Map<String, dynamic> json) {
        filename = json['filename'] != null ? Filename?.fromJson(json['filename']) : null;
        fulltext = json['full_text'];
        sanitycheck = json['sanity_check'] != null ? SanityCheck?.fromJson(json['sanity_check']) : null;
        time = json['time'] != null ? Time?.fromJson(json['time']) : null;
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['filename'] = filename!.toJson();
        data['full_text'] = fulltext;
        data['sanity_check'] = sanitycheck!.toJson();
        data['time'] = time!.toJson();
        return data;
    }
}

class SanityCheck {
    String? front;

    SanityCheck({this.front}); 

    SanityCheck.fromJson(Map<String, dynamic> json) {
        front = json['front'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['front'] = front;
        return data;
    }
}

class Time {
    double? postprocess;
    double? preprocess;
    double? total;

    Time({this.postprocess, this.preprocess, this.total}); 

    Time.fromJson(Map<String, dynamic> json) {
        postprocess = json['post-process'];
        preprocess = json['pre-process'];
        total = json['total'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['post-process'] = postprocess;
        data['pre-process'] = preprocess;
        data['total'] = total;
        return data;
    }
}

