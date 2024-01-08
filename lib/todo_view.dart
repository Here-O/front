import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'map.dart';
import 'mypoints.dart';
import 'todolist.dart';
import 'globals.dart';
import 'todo.dart';
import 'new_todo.dart';
import 'editTodo.dart';

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
  List<todo> my_todoList_c = my_todoList;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void filterTodosBySelectedDate() {
    // formattedSelectedDate에 해당하는 todo 객체들만 필터링
    my_todoList_c = my_todoList;

    log(selectedDate.day.toString());
    formattedSelectedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    log(formattedSelectedDate.toString());

    List<todo> filteredTodos = my_todoList_c.where((todo) {
      return todo.date == formattedSelectedDate; // 날짜 비교
    }).toList();

    setState(() {
      my_todoList_c = filteredTodos;
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1)); // 예시로 2초간 대기 (실제 데이터 로딩 로직으로 대체)

    setState(() {
      filterTodosBySelectedDate();
    });
  }

  @override
  void initState() {
    super.initState();
    filterTodosBySelectedDate();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20),
          SingleChildScrollView(
            //height: 100, // _buildDateScroll에 고정된 높이를 줍니다.
            child: _buildDateScroll(),
          ),
          _buildFirstTodo(),
          _buildAddTodoButton(),
          _buildTodoList(),
        ],
      ),
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
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 9, // Current day + 4 days before and after
        itemBuilder: (context, index) {
          DateTime date = selectedDate.subtract(Duration(days: 4 - index));
          bool isTodayOrBefore = date.isBefore(DateTime.now().add(Duration(days: 0)));
          bool isToday = date.day == DateTime.now().day;
          String day = DateFormat('EEEE').format(date);

          return GestureDetector( // 클릭 이벤트를 위해 GestureDetector 사용
            onTap: () {
              setState(() {
                selectedDate = date;
                log(selectedDate.day.toString());
                filterTodosBySelectedDate();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text(day),
                  CircleAvatar(
                    backgroundColor: isToday ? Colors.green : (isTodayOrBefore ? Colors.blue : Colors.grey),
                    child: Text('${date.day}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirstTodo() {
    if (my_todoList_c.isNotEmpty) {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(my_todoList_c?.first.context ?? 'No todos yet'),
      ),
    );
    } else {
      return Container(
        color: Colors.grey[300],
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('No todos yet'),
        ),
      );
    }
  }

  Widget _buildAddTodoButton() {
    return Align(
      alignment: Alignment.centerRight,
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),

      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TodoResponsePage(selectedDate: selectedDate)));
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
      child: my_todoList_c.isNotEmpty? ListView.builder(
        itemCount: my_todoList_c?.length ?? 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTodo(todoId: my_todoList_c?[index].id ?? '000000')),
              );
            },

            child: ListTile(
            title: Text(my_todoList_c?[index].context ?? 'None todolist context'),
            trailing: Text('${my_todoList_c?[index].point ?? 0}', style: TextStyle(color: Colors.red)),
            tileColor: my_todoList_c[index].done
                ? Colors.lightGreenAccent // todoo.done이 true면 파란색
                : my_todoList_c[index].routine
                ? Colors.yellowAccent // todoo.routine이 true면 노란색
                : null,
          ),
          );
        },
      )
      : Center(child : Text("No items in this day")),
    );
  }
}