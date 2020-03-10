class Token {
  String accessToken;
  String refreshToken;
  String tokenType;
  DateTime validUntil;

  Token(this.accessToken, this.refreshToken, this.validUntil);

  Token.FromJson(dynamic json) {
    accessToken = json['access_token'] as String;
    refreshToken = json['refresh_token'] as String;
    tokenType = json['token_type'] as String;
    var expiresIn = json['expires_in'] as int;
    if (expiresIn != null) {
      validUntil = DateTime.now().add(Duration(seconds: expiresIn));
    }
  }

  bool isValid() => DateTime.now().compareTo(validUntil) < 0;
}
