class Balance {
  double availableBalance;
  String currency;

  Balance.fromJson(Map<String, dynamic> json) {
    availableBalance = json['availableBalance'];
    currency = json['currency'];
  }
}
