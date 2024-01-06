import 'todo.dart';

class TodoList {
  // 유저 ID를 키로 하고, Todo 객체 리스트를 값으로 하는 맵
  Map<String, List<todo>> userTodos = {};

  // Todo 객체를 TodoList에 추가하는 메소드
  void addTodo(todo todo) {
    userTodos.putIfAbsent(todo.user, () => []).add(todo);
  }

  // 특정 유저의 Todo 리스트를 반환하는 메소드
  List<todo> getTodosByUser(String userId) {
    return userTodos[userId] ?? [];
  }

}