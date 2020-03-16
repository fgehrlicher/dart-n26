class Token {
  String accessToken;
  String refreshToken;
  String tokenType;
  DateTime validUntil;

  Token.FromJson(dynamic json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    tokenType = json['token_type'];
    var expiresIn = json['expires_in'];
    if (expiresIn != null) {
      validUntil = DateTime.now().add(Duration(seconds: expiresIn));
    }
  }

  bool get valid => DateTime.now().compareTo(validUntil) < 0;
}
