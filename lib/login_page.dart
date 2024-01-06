import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_email.dart';
import 'user.dart';
import 'map.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  Future<void> signIn() async {
    log('signIn 시작');

    // 입력 유효성 검사
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      log('이메일 또는 비밀번호가 입력되지 않았습니다.');
      Fluttertoast.showToast(
          msg: "이메일 또는 비밀번호가 입력되지 않았습니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return; // 입력이 비어있으면 함수를 더 이상 진행하지 않고 종료합니다.
    }

    try {
      var response = await http.post(
        Uri.parse('http://143.248.193.22:3000/login'), // 서버의 실제 URL로 변경
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'userEmail': emailController.text,
          'password': passwordController.text,
        }),
      );

      log('요청 완료');

      if (response.statusCode == 200) {
        // 로그인 성공 처리
        log('로그인 성공: ${response.body}');
        final jsonResponse = json.decode(response.body);
        User.initialize(jsonResponse["id"], jsonResponse["email"], jsonResponse["name"], jsonResponse["jwt"]);
        User user = User.fromJson(jsonResponse);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => map()));
      } else {
        log('로그인 실패: ${response.body}');
        Fluttertoast.showToast(
            msg: "이메일 또는 비밀번호가 맞지 않습니다",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } catch (e) {
      // 네트워크 요청 중 예외 발생 처리
      log('로그인 요청 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 로고와 타이틀
              Column(
                children: <Widget>[
                  Image.asset('assets/logo.png'),
                ],
              ),
              SizedBox(height: 48.0),
              // 'Welcome back' 텍스트
              Text(
                'Welcome back,\nsign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 48.0),
              // 이메일 입력란
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.person), // 사람 모양 아이콘
                ),
              ),
              SizedBox(height: 12.0),
              // 비밀번호 입력란
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock), // 자물쇠 모양 아이콘
                ),
              ),
              SizedBox(height: 12.0),
              TextButton(
                onPressed: () {},
                child: Text('Forgot password?'),
              ),
              SizedBox(height: 24.0),
              // 로그인 버튼
              ElevatedButton(
                onPressed: signIn,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 16.0),
              // 'Sign Up' 버튼
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_email()));
                },
                child: Text('New User? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}