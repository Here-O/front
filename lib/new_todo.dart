import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hereo/todo_view.dart';
import 'package:intl/intl.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'geo.dart';
import 'todo.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';
import 'todolist.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'todolist.dart';
import 'todo.dart';
import 'map.dart';

class TodoResponsePage extends StatefulWidget {
  final DateTime selectedDate;

  TodoResponsePage({Key? key, required this.selectedDate}) : super(key: key);


  @override
  _TodoResponsePageState createState() => _TodoResponsePageState();

}

class _TodoResponsePageState extends State<TodoResponsePage> {

  TextEditingController _contextController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _pointController = TextEditingController();
  //TextEditingController _queryController = TextEditingController();

  bool _isRoutine = false;
  todo? _todo;

  Future<void> _createTodo() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    log(_contextController.text);
    log(formattedDate);

    if(selected_geo.title == "None") {
      Fluttertoast.showToast(
          msg: "위치를 추가해주세요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    try {
      var response = await http.post(
        Uri.parse('${basicUrl}/todo'),
        headers: <String, String>{
          'Authorization': "Bearer ${User.current.token}",
          'Content-Type': 'application/json'
        },
        body: jsonEncode( {
          'context': _contextController.text,
          'date': formattedDate,
          'latitude': selected_geo.lat,
          'longitude': selected_geo.long,
          'done': false,
          'routine': _isRoutine,
          'point': int.tryParse(_pointController.text) ?? 0,
        }),
      );

      log('${response.body}');

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final todoJson = responseJson["Todo"];
        var todoo = todo.fromJson(todoJson);
        log("todoo 생성 완료");

        todoo.roadAdress = selected_geo.roadAddress;
        my_todoList.add(todoo);

        var token = User.current.token;

      } else {
        log("add failed");
      }
      setState(() {
      });
      Fluttertoast.showToast(msg: '생성 완료');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TodoListTab(loc_auth:false,)));
    } catch(e) {
      log('에러 발생 ${e}');
    }
    selected_geo = geo(title: 'none', mapx: '0', mapy: '0', roadAddress: '대전광역시 유성구 대학로 291 (한국과학기술원)');
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    selectedDate_new = widget.selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: Text('${formattedDate} 투두 작성하기'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contextController,
              decoration: InputDecoration(
                labelText: 'Context',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // TextField 값이 변경될 때마다 UI를 업데이트합니다.
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pointController,
              decoration: InputDecoration(
                labelText: 'Point',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {}); // TextField 값이 변경될 때마다 UI를 업데이트합니다.
              },
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text('Routine'),
              value: _isRoutine,
              onChanged: (bool value) {
                setState(() {
                  _isRoutine = value;
                });
              },
            ),
            Text('${selected_geo.title}',style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '위도: ${selected_geo.lat}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20), // 위도와 경도 사이의 간격
                Text(
                  '경도: ${selected_geo.long}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed :() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      map(status: 1,)),
                );
              },
              child: Text('투두 위치 추가히기'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent, // 배경색은 빨간색
                onPrimary: Colors.white, // 글자색은 흰색
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed : _contextController.text.isNotEmpty&_pointController.text.isNotEmpty ? _createTodo : null,
              child: Text('Create Todo'),
            ),

          ],
        ),
      ),

    );
  }

}
