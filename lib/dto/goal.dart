class Goal {
  String id;
  double amount;

  Goal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
  }
}
