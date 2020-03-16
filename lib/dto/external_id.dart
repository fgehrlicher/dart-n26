class ExternalId {
  String iban;

  ExternalId.fromJson(Map<String, dynamic> json) {
    iban = json['iban'];
  }
}