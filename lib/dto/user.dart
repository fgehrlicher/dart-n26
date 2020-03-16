class User {
  String userId;
  String userRole;

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userRole = json['userRole'];
  }
}
