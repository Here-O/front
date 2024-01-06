import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'map.dart';
import 'mypoints.dart';
import 'todolist.dart';
import 'globals.dart';
import 'todo.dart';

class TodoListTab extends StatefulWidget {
  @override
  _TodoListTabState createState() => _TodoListTabState();
}

class _TodoListTabState extends State<TodoListTab> {
  int _selectedIndex = 1;
  TodoList todoList = TodoList();
  DateTime selectedDate = DateTime.now();
  late String formattedSelectedDate;

  // Dummy list of to-dos for today.
  List<todo>? my_todoList_c = my_todoList;



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void filterTodosBySelectedDate() {
    // formattedSelectedDate에 해당하는 todo 객체들만 필터링

    List<todo>? filteredTodos = my_todoList_c?.where((todo) {
      return todo.date == formattedSelectedDate; // 날짜 비교
    }).toList();

    // 필터링된 리스트로 UI 업데이트
    setState(() {
      my_todoList_c = filteredTodos;
    });
  }

  @override
  void initState() {
    super.initState();
    formattedSelectedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    filterTodosBySelectedDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),
          _buildDateScroll(),
          _buildFirstTodo(),
          _buildAddTodoButton(),
          _buildTodoList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todolist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My points'),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭 인덱스
        selectedItemColor: Colors.purple, // 선택된 아이템의 색상
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => map()));
            _onItemTapped(index);
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TodoListTab()));
            _onItemTapped(index);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPointsPage()));
            _onItemTapped(index);
          }
        },
      ),
    );
  }

  Widget _buildDateScroll() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 9, // Current day + 4 days before and after
        itemBuilder: (context, index) {
          DateTime date = selectedDate.subtract(Duration(days: 4 - index));
          bool isTodayOrBefore = date.isBefore(DateTime.now().add(Duration(days: 1)));
          bool isToday = date.day == DateTime.now().day;

          return Container(
            width: 50,
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: isToday ? Colors.green : (isTodayOrBefore ? Colors.blue : Colors.grey),
                  child: Text('${date.day}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirstTodo() {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(my_todoList_c?.first.context ?? 'No todos yet'),
      ),
    );
  }

  Widget _buildAddTodoButton() {
    return Align(
      alignment: Alignment.centerRight,
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),

      child: ElevatedButton.icon(
        onPressed: () {
          // Add your onPressed logic here
        },
        icon: Icon(Icons.add),
        label: Text('Add Todo'),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Button color
        ),
      ),
    ),
    );
  }

  Widget _buildTodoList() {
    return Expanded(
      child: ListView.builder(
        itemCount: my_todoList_c?.length ?? 0,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(my_todoList_c?[index].context ?? 'None todolist context'),
            trailing: Text('${my_todoList_c?[index].point ?? 0}', style: TextStyle(color: Colors.red)),
          );
        },
      ),
    );
  }
}