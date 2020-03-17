class KycDetail {
  String status;
  String provider;

  KycDetail.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    provider = json['provider'];
  }
}
