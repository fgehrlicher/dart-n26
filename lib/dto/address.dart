class Address {
  String id;
  int created;
  int updated;
  String addressLine1;
  Null addressLine2;
  String streetName;
  String houseNumberBlock;
  String zipCode;
  String cityName;
  Null state;
  String countryName;
  String type;
  String userId;
  bool fromAllowedCountry;

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    updated = json['updated'];
    addressLine1 = json['addressLine1'];
    addressLine2 = json['addressLine2'];
    streetName = json['streetName'];
    houseNumberBlock = json['houseNumberBlock'];
    zipCode = json['zipCode'];
    cityName = json['cityName'];
    state = json['state'];
    countryName = json['countryName'];
    type = json['type'];
    userId = json['userId'];
    fromAllowedCountry = json['fromAllowedCountry'];
  }
}
