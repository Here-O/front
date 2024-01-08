import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;


class geo {
  String title;
  String mapx;
  String mapy;
  String roadAddress;
  String? lat;
  String? long;

  geo({required this.title, required this.mapx, required this.mapy, required this.roadAddress, this.lat, this.long});

  // User 클래스의 싱글턴 인스턴스
  static geo? _instance;

  // 싱글턴 패턴을 위한 팩토리 생성자
  factory geo.fromJson(Map<String, dynamic> json) {
    return geo(
      title: json['title'] as String,
      roadAddress: json['address'] as String,
      mapx: json['mapx'].toString() as String,
      mapy: json['mapy'].toString() as String,
    );
  }

  // 현재 인스턴스에 접근하기 위한 getter
  static geo get current {
    assert(_instance != null, 'geo is not available');
    return _instance!;
  }

  // 인스턴스 초기화
  static void initialize(String title, String mapx, String mapy, String roadAddress, {String? lat, String? long}) {
    _instance = geo(title: title, mapx: mapx, mapy: mapy, roadAddress: roadAddress);
  }

  Future<void> get_latlang() async {
    try {
      var response = await http.get(
        Uri.parse('https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=${roadAddress}'),
        headers: <String, String>{
          'X-NCP-APIGW-API-KEY-ID': "okzqmxz8pr",
          'X-NCP-APIGW-API-KEY': 'dEpiYrVbgl1OeWTX0pgL6NOVVVVH95yti4L63SaF'
        },
      );

      log('${response.body}');


      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        var long_q = responseJson["addresses"][0]["x"];
        var lat_q = responseJson["addresses"][0]["y"];
        log(lat_q);

        lat = lat_q;
        long = long_q;


      } else {
        log("add failed");
      }
    } catch(e) {
      log('에러 발생 ${e}');
    }
  }



}