import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'user.dart';

class map extends StatefulWidget {
  @override
  _map createState() => _map();
}

class _map extends State<map> {

  @override
  Widget build(BuildContext context) {
    var user = User.current;
    var username = user.name;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
