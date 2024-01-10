import 'todo.dart';
import 'geo.dart';

const String basicUrl = 'http://143.248.193.217:3000';
List<todo> my_todoList = [];
List<geo> my_geos = [];
geo selected_geo = geo(title: 'none', mapx: '0', mapy: '0', roadAddress: '위치를 추가해주세요');
DateTime selectedDate_new = DateTime.now();
String selected_todoId = '';

void initializeMyTodoList(List<todo> todos) {
  my_todoList = todos;
}

