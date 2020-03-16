import 'dart:async';
import 'dart:convert';

import 'package:dart_n26/auth.dart';
import 'package:dart_n26/dto/dto.dart';
import 'package:dart_n26/exceptions.dart';
import 'package:http/http.dart' as http;

class Api {
  static const authority = 'api.tech26.de';

  final http.Client _client;
  final Auth _auth;

  Token _token;

  Api(this._client, this._auth);

  /// Triggers the login process. After the future inside [mfaCompleter] is
  /// completed the auth controller will try to retrieve the token.
  /// Throws [InvalidCredentialsException] if the credentials are invalid,
  /// [MfaNotCompletedException] if the mfa challenge is not yet
  /// completed.
  Future<void> authorize(
    String username,
    String password,
    Completer mfaCompleter,
  ) async {
    var mfaToken = await _auth.getMFAToken(username, password);
    await _auth.triggerMFAChallenge(mfaToken);

    await mfaCompleter.future;
    _token = await _auth.completeMfaChallenge(mfaToken);
  }

  /// Gets all transactions found for the specified filters.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<List<Transaction>> getTransactions({
    int limit,
    DateTime from,
    DateTime to,
  }) async {
    var queryParameters = <String, String>{};
    if (limit != null) {
      queryParameters['limit'] = limit.toString();
    }

    if (from != null && to != null) {
      queryParameters['from'] = from.millisecondsSinceEpoch.toString();
      queryParameters['to'] = to.millisecondsSinceEpoch.toString();
    }

    var response = await _sendRequest(
      'GET',
      '/api/smrt/transactions',
      queryParameters: queryParameters,
    );

    List responseBody = await _getJson(response.stream);

    return responseBody.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<http.StreamedResponse> _sendRequest(
    String method,
    String path, {
    Map<String, String> queryParameters,
  }) async {
    if (_token == null || !_token.valid || _token.accessToken == null) {
      throw InvalidAuthTokenException();
    }

    var response = await _client.send(
      _request(
        method,
        path,
        queryParameters: queryParameters,
      ),
    );

    switch(response.statusCode) {
      case 401: {
        throw InvalidAuthTokenException();
      }
      break;

      case 429: {
        throw TooManyRequestsException();
      }
      break;

      case 200: {
        return response;
      }
      break;

      default: {
        throw ApiException(response.statusCode);
      }
    }
  }

  http.BaseRequest _request(
    String method,
    String path, {
    Map<String, String> queryParameters,
  }) {
    var uri = Uri.https(authority, path, queryParameters);
    var request = http.Request(method, uri);
    return _attachAuthHeader(request);
  }

  http.BaseRequest _attachAuthHeader(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer ${_token.accessToken}';
    return request;
  }

  Future<dynamic> _getJson(http.ByteStream byteStream) async {
    var content = await byteStream.bytesToString();
    if (content.isNotEmpty) {
      return jsonDecode(content);
    }
    throw Exception('byteStream must not be empty');
  }
}