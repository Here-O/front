import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'todo.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';
import 'todolist.dart';
import 'package:flutter/material.dart';
import 'user.dart';
import 'todo_view.dart';

class EditTodo extends StatefulWidget {
  final String todoId;

  EditTodo({Key? key, required this.todoId}) : super(key: key);


  @override
  _EditTodo createState() => _EditTodo();

}

class _EditTodo extends State<EditTodo> {

  TextEditingController _contextController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _pointController = TextEditingController();
  bool _isRoutine = false;
  todo? _todo;

  Future<void> _editTodo() async {
    todo? foundTodo = my_todoList.firstWhere(
          (td) => td.id == widget.todoId,
    );
    var id_toedit = foundTodo.id;

    try {
      var response = await http.post(
        Uri.parse('${basicUrl}/todo'),
        headers: <String, String>{
          'Authorization': "Bearer ${User.current.token}",
          'Content-Type': 'application/json'
        },
        body: jsonEncode( {
          'id' : foundTodo.id,
          'context': _contextController.text,
          'date': foundTodo.date,
          'latitude': foundTodo.latitude,
          'longitude': foundTodo.longitude,
          'done': false,
          'routine': _isRoutine,
          'point': int.tryParse(_pointController.text) ?? 0,
        }),
      );

      log('${response.body}');

      if (response.statusCode == 200) {
        my_todoList.removeWhere((td) => td.id == id_toedit);
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
        Fluttertoast.showToast(
            msg: "수정 완료되었습니다",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      });
    } catch(e) {
      log('에러 발생 ${e}');
    }

  }

  Future<void> _deleteTodo() async {
    todo? foundTodo = my_todoList.firstWhere(
          (td) => td.id == widget.todoId,
    );

    var id_todelete = foundTodo.id;

    try {
      var response = await http.delete(
        Uri.parse('${basicUrl}/todo'),
        headers: <String, String>{
          'Authorization': "Bearer ${User.current.token}",
          'Content-Type': 'application/json'
        },
        body: jsonEncode( {
          'id' : foundTodo.id,
        }),
      );

      log('${response.body}');

      if (response.statusCode == 200) {
        my_todoList.removeWhere((td) => td.id == id_todelete);
      } else {
        log("add failed");
      }
      setState(() {
        Fluttertoast.showToast(
            msg: "삭제 완료되었습니다",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TodoListTab()),
        );
      });
    } catch(e) {
      log('에러 발생 ${e}');
    }

  }

  @override
  Widget build(BuildContext context) {
    todo? foundTodo = my_todoList.firstWhere(
          (td) => td.id == widget.todoId,
    );
    if (foundTodo == null) {
      // 일치하는 todo가 있을 경우의 처리
      return Scaffold(
          appBar: AppBar(
            title: Text('${widget.todoId} 에 해당하는 투두가 없습니다'),
          ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('투두 편집하기'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contextController,
              decoration: InputDecoration(
                labelText: '${foundTodo.context}',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pointController,
              decoration: InputDecoration(
                labelText: '${foundTodo.point}',
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

            buttons(),

          ],
        ),
      ),
    );
  }
  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들 사이에 공간을 균등하게 배분
      children: [
        ElevatedButton(
          onPressed: _deleteTodo,
          child: Text('삭제'),
          style: ElevatedButton.styleFrom(
            primary: Colors.red, // 배경색은 빨간색
            onPrimary: Colors.white, // 글자색은 흰색
          ),
        ),
        ElevatedButton(
          onPressed: _editTodo,
          child: Text('수정'),
          style: ElevatedButton.styleFrom(
            primary: Colors.white, // 배경색은 흰색
            onPrimary: Colors.black, // 글자색은 검은색
          ),
        ),
      ],
    );
  }
}
