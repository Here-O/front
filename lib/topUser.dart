class TopUser {
  String id;
  String name;
  int points;
  String image;

  TopUser({required this.id, required this.name, required this.points, required this.image});

  static TopUser? _instance;

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(
      id: json['_id'] as String,
      name: json['userName'] as String,
      points: json['point'] as int,
      image: json['userImage'] as String,
    );
  }

  static TopUser get current{
    assert(_instance != null, 'User has not been initialized yet.');
    return _instance!;
  }

  static void initialize(String id, String name, int points, String image) {
    _instance = TopUser(id: id, name: name, points: points, image: image);
  }


}