import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'user.dart';
import 'mypoints.dart';
import 'todo_view.dart';
import 'globals.dart';
import 'geo.dart';
import 'new_todo.dart';

class map extends StatefulWidget {

  final int status;

  map({Key? key, required this.status}) : super(key: key);

  @override
  _map createState() => _map();
}

class _map extends State<map> {
  int _selectedIndex = 0;
  Location _location = Location();
  late NaverMapController _mapController;
  TextEditingController _searchController = TextEditingController();
  int _selectedIndex_map = 0;

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

  void _showSearch() async {
    log('begin');
    //await Future.delayed(Duration(seconds: 1));
    Set<NAddableOverlay> set_over = {};


    var lat_d = double.parse(selected_geo.lat ?? '36.00');
    var long_d = double.parse(selected_geo.long ?? '137.00');

    var latLng = NLatLng(lat_d, long_d);
    log('latlang build');
    final marker = NMarker(id: 'test', position: latLng);
    log('marker build');
    _mapController.updateCamera(
        NCameraUpdate.fromCameraPosition(
            NCameraPosition(
              target: latLng,
              zoom: 15,
              bearing: 45,
              tilt: 30,
            )));
    set_over.add(marker);

    _mapController.addOverlay(marker);
    log('marker added');


  }

  Future<void> _search() async {
    my_geos = [];
    try {
      var response = await http.Client().get(
        Uri.parse('https://openapi.naver.com/v1/search/local.json?query=${_searchController.text}&display=5'),
        headers: <String, String>{
          'X-Naver-Client-Id': "jHrik9B9QEJ2GzT7HFa0",
          'X-Naver-Client-Secret': 'gMnv3Gvcy7'
        },
      );

      log('${response.body}');

      if (response.statusCode == 200) {
        log("search success");
        final responseJson = json.decode(response.body);

        var total = responseJson['total'];

        for (var geoJson in responseJson["items"]) {
          log(geoJson.toString());


          var geoo = geo.fromJson(geoJson);
          //log('geoo make');
          await geoo.get_latlang();
          //log('get suc');
          geoo.title = geoo.title.replaceAll("<b>", "").replaceAll("</b>", "");
          my_geos.add(geoo);
          //log('add suc');
          log(geoo.lat ?? 'None');
        }

        Fluttertoast.showToast(
            msg: "${total}건 검색 완료",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );


      } else {
        log("add failed");
      }
      setState(() {
        _showSearch();
      });
    } catch(e) {
      log('에러 발생 ${e}');
    }

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

        var latLng = NLatLng(latitude, longitude);
        final marker = NCircleOverlay(id: 'user', center: latLng, radius: 10, color: Colors.blue);

        _mapController.addOverlay(marker);

        var lat_d = double.parse(selected_geo.lat ?? '36.00');
        var long_d = double.parse(selected_geo.long ?? '137.00');
        var latLng_s = NLatLng(lat_d, long_d);

        final marker_s = NMarker(id: 'test', position: latLng_s);

        _mapController.addOverlay(marker_s);
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
        title: Text('${User.current.name}의 지도'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildSearchRow(),
              Expanded(
                child:
                NaverMap(
                  key: _mapKey,
                  options: const NaverMapViewOptions(
                    indoorEnable: true,
                    locationButtonEnable: true,
                    consumeSymbolTapEvents: false,
                  ),
                  onMapReady: (controller) async {
                    mapControllerCompleter.complete(controller);
                    _mapController = controller;
                    log("onMapReady", name:"onMapReady");
                  },
                ),

              ),
              Expanded(
                child: buttonsSearch(),
              ),
            ],
          ),
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
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              contentPadding: EdgeInsets.symmetric(vertical: 15.0),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: _search, // 여기서 _search는 정의되어야 합니다.
          child: Text('검색'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ],
    );
  }

  Widget buttonsSearch() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들 사이에 공간을 균등하게 배분
      children: [
        Expanded(
          child: my_geos.isNotEmpty? ListView.builder(
            itemCount: my_geos?.length ?? 0,
            itemBuilder: (context, index) {
              bool isSelected = index == _selectedIndex_map;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex_map = index;
                    selected_geo = my_geos[_selectedIndex_map];
                  });
                },

                child: ListTile(
                  title: Text(my_geos?[index].title ?? 'None'),
                  tileColor: isSelected ? Colors.grey : Colors.white60,
                ),
              );
            },
          )
              : Center(child : Text("검색 결과가 없습니다")),
        ),
        SizedBox(height: 20,),
        if (widget.status ==1) ElevatedButton(
          onPressed: () {
            selected_geo = my_geos[_selectedIndex_map];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoResponsePage(selectedDate: selectedDate_new)),
            );
          },
          child: Text('반영하기'),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
          ),
        ),

      ],
    );
  }
}
