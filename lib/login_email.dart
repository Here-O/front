import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class login_email extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<login_email> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> signUp() async {
    log('signIn 시작');

    // 입력 유효성 검사
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      log('이메일 또는 비밀번호가 입력되지 않았습니다.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://143.248.193.22:3000/signUp'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'userName': nameController.text,
          'userEmail': emailController.text,
          'password': passwordController.text,
        }),
      );

      log('요청 완료');

      if (response.statusCode == 200) {
        // 로그인 성공 처리
        log('로그인 성공: ${response.body}');
      } else {
        // 서버 응답 오류 처리
        log('로그인 실패: ${response.body}');
      }
    } catch (e) {
      // 네트워크 요청 중 예외 발생 처리
      log('로그인 요청 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // 뒤로 가기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Go Back'),
            ),

            Text(
              'Sign up to Proceed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 48.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 48.0),
            ElevatedButton(
              onPressed: signUp,
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
