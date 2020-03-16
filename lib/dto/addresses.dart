import 'package:dart_n26/dto/address.dart';
import 'package:dart_n26/dto/paging.dart';

class Addresses {
  Paging paging;
  List<Address> addresses;

  Addresses.fromJson(Map<String, dynamic> json) {
    paging = json['paging'] != null ? Paging.fromJson(json['paging']) : null;
    if (json['data'] != null) {
      addresses = List<Address>();
      json['data'].forEach((v) {
        addresses.add(Address.fromJson(v));
      });
    }
  }
}
