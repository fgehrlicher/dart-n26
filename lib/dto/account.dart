class Account {
  String accountType;
  String iban;
  String bic;

  Account.fromJson(Map<String, dynamic> json) {
    accountType = json['accountType'];
    iban = json['iban'];
    bic = json['bic'];
  }
}
