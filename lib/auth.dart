import 'dart:convert';

import 'package:dart_n26/dto/dto.dart';
import 'package:http/http.dart' as http;

class Auth {
  final Map<String, String> _baseHeader = {
    'authorization': 'Basic ' + base64Encode(utf8.encode('android:secret')),
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.86 Safari/537.36',
  };

  final http.Client _client;

  Auth(this._client);

  /// Retrieves a mfa token for a given [user] and [password].
  /// Throws an [InvalidCredentialsException] if the credentials are invalid,
  /// an [NoMfaTokenException] if the api response does not contain a
  /// mfa token and a [AuthApiException] for an unknown error.
  Future<String> getMFAToken(String user, String password) async {
    var uri = Uri.parse('https://api.tech26.de/oauth2/token');
    var fields = {
      'grant_type': 'password',
      'username': user,
      'password': password,
    };

    var response = await _client.send(
      _getMultipartRequest(uri, fields),
    );

    if (response.statusCode == 400) {
      throw InvalidCredentialsException();
    }

    if (response.statusCode != 403) {
      throw AuthApiException(response.statusCode);
    }

    Map<String, dynamic> responseBody = await _getJson(response.stream);

    if (!responseBody.containsKey('mfaToken')) {
      throw NoMfaTokenException();
    }
    return responseBody['mfaToken'] as String;
  }

  /// Triggers a mfa challenge for a given [mfaToken].
  /// Throws an [MfaTriggerException] if the api returns an invalid response.
  Future<void> triggerMFAChallenge(String mfaToken) async {
    var uri = Uri.parse('https://api.tech26.de/api/mfa/challenge');
    var body = json.encode({'challengeType': 'oob', 'mfaToken': mfaToken});

    var response = await _client.send(
      _getRequest(uri, body),
    );

    if (response.statusCode != 201) {
      throw MfaTriggerException();
    }
  }

  /// Completes a mfa challenge for a given [mfaToken].
  /// Throws an [MfaNotCompletedException] if the mfa challenge is
  /// not yet completed.
  Future<Token> completeMfaChallenge(String mfaToken) async {
    var uri = Uri.parse('https://api.tech26.de/oauth2/token');
    var fields = {
      'grant_type': 'mfa_oob',
      'mfaToken': mfaToken,
    };

    var response = await _client.send(
      _getMultipartRequest(uri, fields),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = await _getJson(response.stream);
      return Token.FromJson(responseBody);
    }
    throw MfaNotCompletedException();
  }

  Future<dynamic> _getJson(http.ByteStream byteStream) async {
    var content = await byteStream.bytesToString();
    if (content.isNotEmpty) {
      return jsonDecode(content);
    }
    throw Exception('byteStream must not be empty');
  }

  http.MultipartRequest _getMultipartRequest(
    Uri uri,
    Map<String, String> fields,
  ) {
    var request = http.MultipartRequest('POST', uri);
    _baseHeader.forEach((header, value) {
      request.headers[header] = value;
    });
    fields.forEach((field, value) {
      request.fields[field] = value;
    });
    return request;
  }

  http.Request _getRequest(Uri uri, String jsonBody) {
    var request = http.Request('POST', uri);
    _baseHeader.forEach((header, value) {
      request.headers[header] = value;
    });
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonBody;
    return request;
  }
}

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
