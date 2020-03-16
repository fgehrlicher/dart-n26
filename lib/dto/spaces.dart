import 'package:dart_n26/dto/space.dart';
import 'package:dart_n26/dto/user_features.dart';

class Spaces {
  double totalBalance;
  double visibleBalance;
  List<Space> spaces;
  UserFeatures userFeatures;

  Spaces.fromJson(Map<String, dynamic> json) {
    totalBalance = json['totalBalance'];
    visibleBalance = json['visibleBalance'];
    if (json['spaces'] != null) {
      spaces = List<Space>();
      json['spaces'].forEach((v) {
        spaces.add(Space.fromJson(v));
      });
    }
    userFeatures = json['userFeatures'] != null
        ? UserFeatures.fromJson(json['userFeatures'])
        : null;
  }
}
