import 'package:dart_n26/dto/external_id.dart';
import 'package:dart_n26/dto/user.dart';

class Accounts {
  String id;
  Null physicalBalance;
  double availableBalance;
  double usableBalance;
  double bankBalance;
  String iban;
  String bic;
  String bankName;
  bool seized;
  String currency;
  String legalEntity;
  List<User> users;
  ExternalId externalId;

  Accounts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    physicalBalance = json['physicalBalance'];
    availableBalance = json['availableBalance'];
    usableBalance = json['usableBalance'];
    bankBalance = json['bankBalance'];
    iban = json['iban'];
    bic = json['bic'];
    bankName = json['bankName'];
    seized = json['seized'];
    currency = json['currency'];
    legalEntity = json['legalEntity'];
    if (json['users'] != null) {
      users = List<User>();
      json['users'].forEach((v) {
        users.add(User.fromJson(v));
      });
    }
    externalId = json['externalId'] != null
        ? ExternalId.fromJson(json['externalId'])
        : null;
  }
}
