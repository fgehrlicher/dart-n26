class AuthApiException implements Exception {
  int statusCode;

  AuthApiException(this.statusCode);

  @override
  String toString() => 'unkown error. status code: $statusCode';
}

class InvalidCredentialsException implements Exception {
  @override
  String toString() => 'Invalid credentials';
}

class NoMfaTokenException implements Exception {
  @override
  String toString() => 'No mfa token found in response';
}

class MfaTriggerException implements Exception {
  @override
  String toString() => 'Cant trigger mfa';
}

class MfaNotCompletedException implements Exception {
  @override
  String toString() => 'Mfa not yet completed';
}

class InvalidAuthTokenException implements Exception {
  @override
  String toString() => 'Auth token invalid';
}

class TooManyRequestsException implements Exception {
  @override
  String toString() => 'Too Many Requests';
}

class ApiException implements Exception {
  int statusCode;

  ApiException(this.statusCode);

  @override
  String toString() => 'Unkown error. status code: $statusCode';
}
