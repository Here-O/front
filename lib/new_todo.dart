import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'todo.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';
import 'todolist.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'todolist.dart';
import 'todo.dart';

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
  TextEditingController _queryController = TextEditingController();

  bool _isRoutine = false;
  todo? _todo;

  Future<void> _createTodo() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    log(_contextController.text);
    log(formattedDate);

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
          'latitude': '36.00',
          'longitude': '80.00',
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
        my_todoList.add(todoo);

        var token = User.current.token;

      } else {
        log("add failed");
      }
      setState(() {
        _todo = todo(
          context: _contextController.text,
          date: _dateController.text,
          point: int.tryParse(_pointController.text) ?? 0,
          routine: _isRoutine,
          done: false,
          user: User.current.id,
          latitude: '36.00',
          longitude:'80.00',
        );
      });
    } catch(e) {
      log('에러 발생 ${e}');
    }

  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

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
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pointController,
              decoration: InputDecoration(
                labelText: 'Point',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed : _createTodo,
              child: Text('Create Todo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed : _createTodo,
              child: Text('Create Todo'),
            ),
          ],
        ),
      ),

    );
  }

}
