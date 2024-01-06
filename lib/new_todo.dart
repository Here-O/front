import 'dart:convert';
import 'todo.dart';
import 'todolist.dart';
import 'package:flutter/material.dart';
import 'user.dart';

class TodoResponsePage extends StatefulWidget {
  @override
  _TodoResponsePageState createState() => _TodoResponsePageState();
}

class _TodoResponsePageState extends State<TodoResponsePage> {
  TextEditingController _contextController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _pointController = TextEditingController();
  bool _isRoutine = false;
  todo? _todo;

  void _createTodo() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Todo'),
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
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date',
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
              onPressed: _createTodo,
              child: Text('Create Todo'),
            ),
            SizedBox(height: 20),
            if (_todo != null) _buildTodoDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Context: ${_todo!.context}', style: TextStyle(fontSize: 16)),
        Text('Date: ${_todo!.date}', style: TextStyle(fontSize: 16)),
        Text('Point: ${_todo!.point}', style: TextStyle(fontSize: 16)),
        Text('Routine: ${_todo!.routine}', style: TextStyle(fontSize: 16)),
        // 기타 필요한 필드들을 여기에 표시합니다.
      ],
    );
  }
}
