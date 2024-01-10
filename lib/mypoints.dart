import 'dart:developer';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hereo/topUser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
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
  List<dynamic> completedTodoList = [];
  List<dynamic> completedTodoList_top = [];
  final ImagePicker _picker = ImagePicker();

  Future<http.MultipartFile> getImageMultipartFile(String imagePath) async {
    // 파일의 MIME 타입을 가져옵니다.
    final mimeTypeData = lookupMimeType(imagePath, headerBytes: [0xFF, 0xD8])?.split('/');

    // 이미지 파일을 MultipartFile로 변환합니다.
    final imageMultipartFile = await http.MultipartFile.fromPath(
      'image', // 서버에서 인식할 필드명
      imagePath,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    );

    return imageMultipartFile;
  }

  Future<void> _pickAndSaveImage() async {
    // 갤러리에서 이미지를 선택합니다.
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 임시 디렉터리에 파일을 저장합니다.
      final imageTemporary = File(pickedFile.path);
      final directory = await getApplicationDocumentsDirectory();
      final name = path.basename(imageTemporary.path);
      final imagePermanent = await imageTemporary.copy('${directory.path}/$name');

      // 파일의 MIME 타입을 가져옵니다.
      final mimeTypeData = lookupMimeType(imagePermanent.path, headerBytes: [0xFF, 0xD8])?.split('/');

      // MultipartRequest를 생성합니다.
      var request = http.MultipartRequest("PATCH", Uri.parse('${basicUrl}/mypage/image'))
        ..headers['Authorization'] = 'Bearer ${User.current.token}'
        ..files.add(await http.MultipartFile.fromPath(
          'image', // 서버에서 인식할 필드명
          imagePermanent.path,
          contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
        ));

      try {
        // 요청을 전송하고 응답을 기다립니다.
        var response = await request.send();
        final responseString = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          log("Image upload success");
          final responseJson = json.decode(responseString);
          Fluttertoast.showToast(msg: '${responseJson["message"].toString()}');
        } else {
          log("Image upload failed: $responseString");
        }
      } catch (e) {
        log('에러 발생: $e');
      }
    }
  }

  void onImageTap(TopUser user, BuildContext context) async {
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
          completedTodoList_top = [];
          completedTodoList_top = responseJson["completedTodoList"];
          log('completedTodoList updated: ${completedTodoList}');
        });

        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            log('Show dialog for user ${user.name}');
            return AlertDialog(
              title: Text('${user.name}의 Todos'),
              content: _buildCompletedTodoList_top(),
              backgroundColor: Colors.white,
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(); // 팝업 닫기
                  },
                ),
              ],
            );
          },
        );
      } else {
        Fluttertoast.showToast(msg: 'Failed to load completed todos');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

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
        User.current.image = responseUser["userImage"] ?? "defaultImage";
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
        for (var todoJson in responseJson["Todo"]) {
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

            _buildPointsSection(),

            _buildFriendsScrollList(),
            // 필터 버튼

            // 투두리스트 달성 현황
            SingleChildScrollView(
                child:Column(
                  children: [
                    //_buildFilterButtons(),
                    _buildTodoListStatus(my_todo),
                    _buildCompletedTodoList(),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => TodoListTab(loc_auth: false,)));
            _onItemTapped(index);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPointsPage()));
            _onItemTapped(index);
          }
        },
      ),
    );
  }


  Widget _buildCompletedTodoList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: completedTodoList.length,
      itemBuilder: (BuildContext context, int index) {
        var todoo = completedTodoList[index];
        return Column(
        children: <Widget> [
        ListTile(
          title: Text(todoo["context"]),
          subtitle: Text(todoo["date"]),
          trailing: Text('${todoo["point"]} P+', style: TextStyle(color: Colors.red)),
          tileColor: todoo["done"] ? Colors.blue.shade200 : null,
        ),
          Divider(color: Colors.white60, thickness: 2.5, height: 2.5,),
        ],
        );
      },
    );
  }

  Widget _buildCompletedTodoList_top() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: completedTodoList_top.length,
      itemBuilder: (BuildContext context, int index) {
        var todoo = completedTodoList_top[index];
        return Column(
          children: <Widget>[
            ListTile(
              title: Text(todoo["context"]),
              subtitle: Text(todoo["date"]),
              trailing: Text('${todoo["point"]} P+', style: TextStyle(color: Colors.red)),
              tileColor: todoo["done"] ? Colors.green.shade200 : null,
            ), Divider(color: Colors.white60, thickness: 1, height: 1,),
          ],
        ) ;
      },
    );
  }

  Widget _buildPointsSection() {
    final userName = User.current?.name;
    final userPoints = User.current?.points;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector( // 클릭 이벤트를 위해 GestureDetector 사용
          onTap: () {
            _pickAndSaveImage();
          },
      child:  Column (
        children: <Widget> [
              CircleAvatar(
                  radius: 70.0,
                   child: ClipOval(
                     child: Image.network(
                       User.current.image ?? "defaultImage",
                       width: 150.0, // 이미지의 너비 조절
                        height: 150.0, // 이미지의 높이 조절
                        fit: BoxFit.cover, // 이미지가 영역을 채우도록 조절
                        ),
                   ),
              ),
            SizedBox(height: 5,),
    ],
    ),
    ),
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
            onTap: () => onImageTap(user, context),
            child:  Column (
            children: <Widget> [
              CircleAvatar(
                radius: 50.0,
                child: ClipOval(
                      child: Image.network(
                        user.image,
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                ),
              SizedBox(height: 5,),
              Row(
                children: [
                  SizedBox(width: 30,),
                  Text('${user.name}',style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                  SizedBox(width: 2,),
                  Text('${user.points}P', style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
                  SizedBox(width: 30,),
                ],
              ),

              ],
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
      return Column(
        children: [
      ListTile(
      title: Text(todoo.context), // Todo의 context 표시
      subtitle: Text(todoo.date), // Todo의 date 표시
      trailing: Text('${todoo.point} P+', style: TextStyle(color: Colors.red)),
      tileColor:todoo.done
      ? Colors.lightBlue.shade100
          : null,

      ),  Divider(color: Colors.white60, thickness: 1, height: 1,),
        ],
      );
    },
  );
}