import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;




void main() async{
  await _initialize();
  runApp(MyApp());
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
    clientId: 'okzqmxz8pr',
    onAuthFailed: (e) => log("navermap failed: $e", name: "onAuthFailed")
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo List Authentication App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column을 중앙에 위치시킵니다.
          children: <Widget>[
            SizedBox(height: 20), // Text와 Image 사이의 간격을 주기 위한 SizedBox
            Image.asset('assets/logo.png'), // 이미지를 표시하는 위젯
          ],
        ),
      ),
    );
  }
}
