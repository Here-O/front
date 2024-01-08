import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hereo/todo_view.dart';

import 'globals.dart';

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

  Future<void>
  signUp() async {
    log("signUp");

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "이메일 또는 비밀번호가 입력되지 않았습니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );

      // 비번 != 비번확인 경우
      if (passwordController.text != confirmPasswordController.text) {
        Fluttertoast.showToast(msg: "비밀번호를 다시 확인해주세요",
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
          Uri.parse('${basicUrl}/signUp'),
          headers: <String, String>{
            'Context-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'userEmail': emailController.text,
            'userName': userNameController.text,
            'password': passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          log('회원가입 성공');
          // Navigator.push, Navigator.pushReplacement로 새 화면 전환
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TodoListTab()));
        } else {
          log('이미 가입된 이메일입니다.');
          Fluttertoast.showToast(
              msg: "이미 가입된 이메일입니다.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      } catch (e) {
        log('로그인 요청 중 오류 발생: $e');
      }
    }

    // Scaffold: 화면을 상중하로 나눠줌
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
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'enter your email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    labelText: 'enter your username',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'enter your password',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}