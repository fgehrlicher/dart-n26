class Limit {
  String limit;
  double amount;
  String countryList;

  Limit.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    amount = json['amount'];
    countryList = json['countryList'];
  }
}
