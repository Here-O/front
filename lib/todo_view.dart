import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hereo/user.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'geo.dart';
import 'map.dart';
import 'mypoints.dart';
import 'todolist.dart';
import 'globals.dart';
import 'todo.dart';
import 'new_todo.dart';
import 'editTodo.dart';

class TodoListTab extends StatefulWidget {
  final bool loc_auth;

  TodoListTab({Key? key, required this.loc_auth}) : super(key: key);

  @override
  _TodoListTabState createState() => _TodoListTabState();
}

class _TodoListTabState extends State<TodoListTab> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  TodoList todoList = TodoList();
  DateTime selectedDate = DateTime.now();
  late int _selectedTodo = 0;

  late String formattedSelectedDate;
  late AnimationController controller;
  bool isDragged = false;
  bool loc_auth_t = false;

  // Dummy list of to-dos for today.
  List<todo> my_todoList_c = my_todoList;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> gettodo(User user) async {
    // todo 조회
    try {
      var response = await http.post(
        Uri.parse('${basicUrl}/points'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${User.current.token}',
        },
        body: jsonEncode({'id': user.id}),
      );
      log("onImageTap_userId: ${user.id}");

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        setState(() {
          my_todoList = responseJson["completedTodoList"];
          my_todoList_c = my_todoList;
          log('completedTodoList updated: ${my_todoList_c}');
        });
      }
    } catch (e) {
      // 네트워크 요청 중 예외 발생 처리
      log('todolist 조회 중 오류 발생: $e');
    }
  }

  Future<void> filterTodosBySelectedDate() async {
    log('start');
    if (widget.loc_auth) {
      Fluttertoast.showToast(msg: '해당 투두 인증 완료');
      int index = my_todoList.indexWhere((todo) => todo.id == selected_todoId);
      if (index != -1) {
        my_todoList[index].done = true;
        log('edit success');
      }
      try {
        var response = await http.post(
          Uri.parse('${basicUrl}/todo'),
          headers: <String, String>{
            'Authorization': "Bearer ${User.current.token}",
            'Content-Type': 'application/json'
          },
          body: jsonEncode( {
            'id' : my_todoList[index].id,
            'context': my_todoList[index].context,
            'date': my_todoList[index].date,
            'latitude': my_todoList[index].latitude,
            'longitude': my_todoList[index].longitude,
            'done': true,
            'routine': my_todoList[index].routine,
            'point': my_todoList[index].point,
          }),
        );

        log('${response.body}');

        if (response.statusCode == 200) {
          my_todoList.removeWhere((td) => td.id == selected_todoId);
          final responseJson = json.decode(response.body);
          final todoJson = responseJson["Todo"];
          var todoo = todo.fromJson(todoJson);
          //log("todoo 생성 완료");
          my_todoList.add(todoo);
        } else {
          log("add failed");
        }

      } catch(e) {
        log('에러 발생 ${e}');
      }
      setState(() {

      });
    }
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

    initializeDateFormatting('ko_KR', null); // 한국어 로케일 초기화
    filterTodosBySelectedDate();
    gettodo(User.current);
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedDate.month.toString()}월 ${selectedDate.day.toString()}일의 투두리스트'),
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
          SizedBox(height: 8,),
          _buildFirstTodo(),
          //_buildAddTodoButton(),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => map(status: 0,)));
            _onItemTapped(index);
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TodoListTab(loc_auth: false,)));
            _onItemTapped(index);
          } else {

            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPointsPage()));
            _onItemTapped(index);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TodoResponsePage(selectedDate: selectedDate)));
        },
        child: Icon(Icons.add, color: Colors.white,

      ),
        backgroundColor: Colors.green.shade300,
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
          String day = DateFormat('E','ko_KR').format(date);

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
                    backgroundColor: isToday ? Colors.yellow.shade300 : (isTodayOrBefore ? Colors.green.shade300 : Colors.grey.shade200),
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
        alignment: Alignment.center,
        child: Text('오늘 하루를 가볍게 시작해보세요!', style: TextStyle(
          color: Colors.black54, // 색상을 좀 더 연하게 설정합니다.
          fontWeight: FontWeight.w300, // 글자 두께를 줄여서 텍스트를 연하게 만듭니다.
        ),),
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
        icon: Icon(Icons.add, color: Colors.white,),
        label: Text('Add Todo', style: TextStyle(color: Colors.white60)),
        style: ElevatedButton.styleFrom(
          primary: Colors.green.shade300, // Button color
        ),
      ),
    ),
    );
  }
  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      selected_todoId = my_todoList_c[_selectedTodo].id;
      isDragged = !isDragged;
      isDragged ? controller.forward() : controller.reverse();
    });

    selected_geo = geo(title: my_todoList_c[_selectedTodo].context, mapx: '0', mapy: '0', roadAddress: '대전광역시 유성구 대학로 291 (한국과학기술원)');
    selected_geo.lat = my_todoList_c[_selectedTodo].latitude;
    selected_geo.long = my_todoList_c[_selectedTodo].longitude;
    selected_geo.roadAddress = my_todoList_c[_selectedTodo].roadAdress ?? '대전광역시 유성구 대학로 291 (한국과학기술원)';

    log(selected_geo.roadAddress);
    log(selected_geo.title);

    Future.delayed(Duration(milliseconds: 550), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => map(status: 2)),
      );
    });
  }
  Widget _buildTodoList() {
    return Expanded(
      child: my_todoList_c.isNotEmpty? ListView.builder(
        itemCount: my_todoList_c?.length ?? 0,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
          GestureDetector(
          onHorizontalDragStart: (details) {
            _selectedTodo = index;
          },
          onTap: () {
          setState(() {
          _selectedTodo = index;
          selected_todoId = my_todoList_c[_selectedTodo].id;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EditTodo(todoId: selected_todoId,)));
          });
          },
          onHorizontalDragEnd:  _handleDragEnd,
          child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          decoration: BoxDecoration(
          gradient: isDragged & (index == _selectedTodo)
          ? LinearGradient(
          colors: [Colors.grey, Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          )
              : LinearGradient(
          colors: [my_todoList_c[index].done? Colors.blue.shade100 : Colors.white, my_todoList_c[index].done? Colors.blue.shade200 : Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          ),
          ),

          child: ListTile(
          title: Text(my_todoList_c?[index].context ?? 'None todolist context'),
          trailing: Text('${my_todoList_c?[index].point ?? 0}', style: TextStyle(color: Colors.red)),
          ),
          ),
          ),
              Divider(
                color: Colors.grey.shade300, // 색상을 회색으로 설정
                thickness: 0.8, // 선의 두께를 1로 설정
                height: 1, // Divider 위젯의 높이를 1로 설정하여 간격을 최소화
              ),
            ],
          );
        },
      )
          : Center(child : Text("No items in this day")),
    );
  }
}