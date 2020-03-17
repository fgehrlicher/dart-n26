import 'package:dart_n26/dto/balance.dart';
import 'package:dart_n26/dto/goal.dart';

class Space {
  String id;
  String accountId;
  String name;
  String imageUrl;
  String backgroundImageUrl;
  Balance balance;
  bool isPrimary;
  bool isHiddenFromBalance;
  bool isCardAttached;
  bool isLocked;
  Goal goal;

  Space.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['accountId'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    backgroundImageUrl = json['backgroundImageUrl'];
    balance =
        json['balance'] != null ? Balance.fromJson(json['balance']) : null;
    isPrimary = json['isPrimary'];
    isHiddenFromBalance = json['isHiddenFromBalance'];
    isCardAttached = json['isCardAttached'];
    isLocked = json['isLocked'];
    goal = json['goal'] != null ? Goal.fromJson(json['goal']) : null;
  }
}
