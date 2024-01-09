import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hereo/topUser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'todo.dart';
import 'user.dart';
import 'todolist.dart';
import 'globals.dart';
import 'map.dart';
import "todo_view.dart";

class MyPointsPage extends StatefulWidget {
  @override

  _MyPointsPage createState() => _MyPointsPage();
}

class _MyPointsPage extends  State<MyPointsPage> {
  TodoList todoList = TodoList();
  int _selectedIndex = 2;
  List<TopUser> topUsers = [];

  @override
  void initState() {
    super.initState();
    gettodo();
    updateUser();
    getTopPoints();

  }
  Future<void> updateUser() async {  // 마이페이지 정보 확인
    try {
      var response = await http.get(
        Uri.parse('${basicUrl}/mypage'),
        headers: <String, String>{
          'Authorization': "Bearer ${User.current.token}"
        },
      );
      log('${response.body}');
      if (response.statusCode == 200) {

        final responseJson = json.decode(response.body);
        final responseUser = responseJson["loginUser"][0];
        var token = User.current.token;
        log("${responseUser["point"]}");
        User.update(responseUser["_id"], responseUser["userEmail"], responseUser["userName"], token, responseUser["point"]);
      }
      setState(() {
        // UI 업데이트를 위해 setState 호출
      });

    } catch(e) {
      log('에러 발생 ${e}');
    }
  }

  Future<void> getTopPoints() async {
    log('포인트 상위 5명 조회하기');
    try {
      var response = await http.get(
        Uri.parse('${basicUrl}/points/top'),
        headers: <String, String>{
          'Authorization': 'Bearer ${User.current.token}'
        },
      );

      log('요청 완료');
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        List<TopUser> loadedTopUsers = [];

        for (var topUserJson in responseJson["topUsers"]) {
          loadedTopUsers.add(TopUser.fromJson(topUserJson));
        }
        setState(() {
          topUsers = loadedTopUsers;  // 상태변수 업데이트
        });

      } else{
        log('TopUsers 조회 실패: ${response.body}');
      }

    } catch (e) {
      log('에러발생 ${e}');
    }
  }

  Future<void> gettodo() async {  // todo 조회
    log('todolist 불러오기');
    log('${User.current.token}');

    try {
      var response = await http.get(
        Uri.parse('${basicUrl}/todo'),
        headers: <String, String>{
          'Authorization': "Bearer ${User.current.token}"
        },
      );

      log('요청 완료');

      if (response.statusCode == 200) {
        // 로그인 성공 처리
        log('todolist 조희 성공: ${response.body}');

        final responseJson = json.decode(response.body);

        //log("for 처리 전");
        for (var todoJson in responseJson["Todo"]) {  // json객체 내에 Todo에 해당하는 데이터처리 반복
          //log("todoo 생성 전");
          //log(todoJson.toString());
          var todoo = todo.fromJson(todoJson);
          log("todoo 생성 완료");
          todoList.addTodo(todoo);
          //log("for 처리 중");
        }
        setState(() {
          // UI 업데이트를 위해 setState 호출
        });

        return;

      } else {
        log('todolist 조회 실패: ${response.body}');

      }
    } catch (e) {
      // 네트워크 요청 중 예외 발생 처리
      log('todolist 조회 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var my_todo = todoList.getTodosByUser(User.current.id);
    my_todoList = my_todo;
    //log(my_todo as String);

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }
    return Scaffold(

      appBar: AppBar(
        title: Text('My points'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 사용자의 포인트와 이름을 표시하는 섹션
            _buildPointsSection(),
            // 친구들의 원형 아이콘 리스트
            _buildFriendsScrollList(),
            // 필터 버튼

            // 투두리스트 달성 현황
            SingleChildScrollView(
                child:Column(
                  children: [
                    _buildFilterButtons(),
                    _buildTodoListStatus(my_todo),
                  ],
                )
            ),
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

  Widget _buildPointsSection() {
    final userName = User.current?.name;
    final userPoints = User.current?.points;

    return Padding(

      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('$userName 님의 포인트', style: TextStyle(fontSize: 16)),
          Text('$userPoints P', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFriendsScrollList() {
    return Container(
      height: 150.0, // 친구 아이콘의 반지름에 맞춰 높이를 조절합니다.
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topUsers.length, // 친구의 수에 따라 조절
        itemBuilder: (BuildContext context, int index) {
          TopUser user = topUsers[index];
          return GestureDetector( // 클릭 이벤트를 위해 GestureDetector 사용
            onTap: () {
              print('Avatar ${user.name} clicked');
            },
            child: Expanded(
            child:  Column (
            children: <Widget> [
              CircleAvatar(
                radius: 50.0, // 반지름을 50.0으로 설정하여 크기를 키웁니다.
                child: ClipOval(
                      child: Image.network(
                        user.image,
                        width: 100.0, // 이미지의 너비 조절
                        height: 100.0, // 이미지의 높이 조절
                        fit: BoxFit.cover, // 이미지가 영역을 채우도록 조절
                      ),
                    ),
                ),
              SizedBox(height: 5,),
              Row(
                children: [
                  Text('${user.name}',style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                  SizedBox(width: 2,),
                  Text('${user.points}P', style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
                ],
              )

              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildFilterButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildFilterButton('1주일'),
      _buildFilterButton('1개월'),
      _buildFilterButton('전체'),
    ],
  );
}

Widget _buildFilterButton(String label) {
  return ElevatedButton(
    onPressed: () {
      // 필터링 로직 구현
    },
    child: Text(label),
  );
}

Widget _buildTodoListStatus(dynamic my_todo) {
  //log(my_todo.toString());

  return ListView.builder(
    scrollDirection: Axis.vertical,
    shrinkWrap: true, // Column 내부 ListView 사용 시 필요
    physics: NeverScrollableScrollPhysics(),
    itemCount: my_todo?.length ?? 0,
    itemBuilder: (BuildContext context, int index) {
      todo todoo = my_todo[index];
      //log(todoo as String);
      return ListTile(
        title: Text(todoo.context), // Todo의 context 표시
        subtitle: Text(todoo.date), // Todo의 date 표시
        trailing: Text('${todoo.point} P+', style: TextStyle(color: Colors.red)),
        tileColor:todoo.done
            ? Colors.lightBlue // todoo.done이 true면 파란색
            : null,

      );
    },
  );
}