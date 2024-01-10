import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hereo/todo_view.dart';

import 'globals.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {

  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {

  // 이메일, 이름, 비밀번호, 비밀번호 확인
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    log("signUp");

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "이메일 또는 비밀번호가 입력되지 않았습니다");
      log('c 1');
      return;
    }
    // 비번 != 비번확인 경우
    if (passwordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "비밀번호를 다시 확인해주세요",);
      log('c 2');
      return;
    }
    try {
      var response = await http.post(
        Uri.parse('${basicUrl}/signUp'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'userEmail': emailController.text.toString(),
          'userName': userNameController.text.toString(),
          'password': passwordController.text.toString(),
        }),
      );

      if (response.statusCode == 200) {
        log('회원가입 성공');
        Fluttertoast.showToast(
          msg: "회원가입 완료",
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        log('이미 가입된 이메일입니다.');
        Fluttertoast.showToast(
            msg: "이미 가입된 이메일입니다.",
        );
      }
    } catch (e) {
      log('로그인 요청 중 오류 발생: $e');
    }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("HereO 회원가입"),
          backgroundColor: Colors.white, // AppBar 배경을 흰색으로 설정
          foregroundColor: Colors.black, // AppBar의 텍스트 및 아이콘 색상을 검은색으로 설정
        ),
        backgroundColor: Colors.white, // 화면 배경을 흰색으로 설정
        body: SafeArea(
          child: SingleChildScrollView( // 스크롤 가능하게 만듦
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 10,),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      labelText: 'username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'confirm password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  ElevatedButton(
                    child: Text('회원가입'),
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // 버튼의 배경색을 변경
                      onPrimary: Colors.white, // 버튼의 글자색을 흰색으로 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    child: Text('홈으로 돌아가기'),
                    onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white60,
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

}
