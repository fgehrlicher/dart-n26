import 'package:dart_n26/dto/account.dart';

class Contact {
  String userId;
  String id;
  String name;
  String subtitle;
  Account account;

  Contact.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    name = json['name'];
    subtitle = json['subtitle'];
    account =
        json['account'] != null ? Account.fromJson(json['account']) : null;
  }
}
