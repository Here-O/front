import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;


class todo {
  String context;
  String date;
  String latitude;
  String longitude; // 인증 토큰 등 추가적인 정보를 저장할 수 있습니다.
  bool done;
  bool routine;
  var point;
  String user;
  var id;
  DateTime? doneAt;
  String? roadAdress;

  todo({required this.context, required this.date, required this.latitude, required this.longitude,
    required this.done, required this.routine, this.point, required this.user, this.id, this.doneAt});

  // User 클래스의 싱글턴 인스턴스
  static todo? _instance;

  // 싱글턴 패턴을 위한 팩토리 생성자
  factory todo.fromJson(Map<String, dynamic> json) {
    return todo(
      context: json['context'] as String,
      date: json['date'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      done: json['done'] as bool,
      routine: json['routine'] as bool,
      point: json['point'] as int,
      user: json['user'] as String,
      id: json['_id'] as String,
      doneAt: json['doneAt'] != null ? DateTime.parse(json['doneAt']) : null,
    );
  }

  // 현재 인스턴스에 접근하기 위한 getter
  static todo get current {
    assert(_instance != null, 'todo is not available');
    return _instance!;
  }

  // 인스턴스 초기화
  static void initialize(String context, String date, String latitude, String longtitude, bool done, bool routine, String point, String user) {
    _instance = todo(context: context, date: date, latitude: latitude, longitude: longtitude, done: done, routine: routine, point: point, user: user);
  }


  // 인스턴스 정보 업데이트
  static Future<void> update({String? context, String? date, String? latitude, String? longitude, bool? done, bool? routine, String? point, String? id}) async {
    if (_instance != null) {
      try {
        var response = await http.post(
          Uri.parse('http://143.248.193.22:3000/todo'), // 서버의 실제 URL로 변경
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'context': context,
            'date': date,
            'latitude': latitude,
            'longitude': longitude,
            'done': done,
            'routine': routine,
            'point': point,
            '_id': id,
          }),
        );
        if (response.statusCode == 200) {
          log('edit success');
          return;

        } else {
          log('edit failed');
          return;

        }
      } catch (e) {
        log('error occurred');
    }

    }
  }


}