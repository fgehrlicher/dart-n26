class Balance {
  double availableBalance;
  String currency;

  Balance.fromJson(Map<String, dynamic> json) {
    availableBalance = double.parse(json['availableBalance'].toString());
    currency = json['currency'];
  }
}
