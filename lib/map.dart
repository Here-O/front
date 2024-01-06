import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';
import 'user.dart';
import 'mypoints.dart';
import 'todo_view.dart';

class map extends StatefulWidget {
  @override
  _map createState() => _map();
}

class _map extends State<map> {
  int _selectedIndex = 0;
  Location _location = Location();
  late NaverMapController _mapController;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      log("Location permission granted.");
      _location.onLocationChanged.listen((LocationData currentLocation) {
        log("user_loc success");
        double latitude = currentLocation.latitude ?? 0.0;
        double longitude = currentLocation.longitude ?? 0.0;
        log("before updateCamera");
        log(latitude.toString());
        log(longitude.toString());
        _mapController.updateCamera(
            NCameraUpdate.fromCameraPosition(
                NCameraPosition(
                    target: NLatLng(latitude, longitude),
                    zoom: 15,
                    bearing: 45,
                    tilt: 30,
                )));

      });
    } else if (status.isDenied) {
      log("Location permission denied.");
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // 앱 설정을 열어 사용자가 수동으로 권한을 허용할 수 있도록 함
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = User.current;
    var username = user.name;
    final Completer<NaverMapController> mapControllerCompleter = Completer();
    GlobalKey _mapKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: Text('Map ${User.current.name}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Expanded(
              child: NaverMap(
                key: _mapKey,
              options: const NaverMapViewOptions(
                indoorEnable: true,
                locationButtonEnable: true,
                consumeSymbolTapEvents: false,
              ),
              onMapReady: (controller) async {
                //_mapController = controller;
                mapControllerCompleter.complete(controller);
                log("onMapReady", name:"onMapReady");
              },
            ),)

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


}
