import 'dart:async';
import 'dart:convert';

import 'package:dart_n26/auth.dart';
import 'package:dart_n26/dto/accounts.dart';
import 'package:dart_n26/dto/addresses.dart';
import 'package:dart_n26/dto/card.dart';
import 'package:dart_n26/dto/contact.dart';
import 'package:dart_n26/dto/dto.dart';
import 'package:dart_n26/dto/limit.dart';
import 'package:dart_n26/dto/profile.dart';
import 'package:dart_n26/dto/spaces.dart';
import 'package:dart_n26/dto/status.dart';
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

  /// Retries the Profile.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<Profile> getProfile() async {
    var response = await _sendRequest('GET', '/api/me');
    Map responseBody = await _getJson(response.stream);
    return Profile.fromJson(responseBody);
  }

  /// Returns all Accounts.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<Accounts> getAccounts() async {
    var response = await _sendRequest('GET', '/api/accounts');
    Map responseBody = await _getJson(response.stream);
    return Accounts.fromJson(responseBody);
  }

  /// Returns all Statuses.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<Status> getStatuses() async {
    var response = await _sendRequest('GET', '/api/me/statuses');
    Map responseBody = await _getJson(response.stream);
    return Status.fromJson(responseBody);
  }

  /// Returns all Addresses.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<Addresses> getAddresses() async {
    var response = await _sendRequest('GET', '/api/addresses');
    Map responseBody = await _getJson(response.stream);
    return Addresses.fromJson(responseBody);
  }

  /// Returns all Cards.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<List<Card>> getCards() async {
    var response = await _sendRequest('GET', '/api/v2/cards');
    List responseBody = await _getJson(response.stream);
    return responseBody.map((e) => Card.fromJson(e)).toList();
  }

  /// Returns all Limits.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<List<Limit>> getLimits() async {
    var response = await _sendRequest('GET', '/api/settings/account/limits');
    List responseBody = await _getJson(response.stream);
    return responseBody.map((e) => Limit.fromJson(e)).toList();
  }

  /// Returns all Contacts.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<List<Contact>> getContacts() async {
    var response = await _sendRequest('GET', '/api/smrt/contacts');
    List responseBody = await _getJson(response.stream);
    return responseBody.map((e) => Contact.fromJson(e)).toList();
  }

  /// Returns all Spaces.
  /// Throws [InvalidAuthTokenException] if the token expired or the
  /// return status code is equal to 401, [TooManyRequestsException] if the
  /// request status code is equal to 429 and [ApiException] if the response
  /// code does not match 200.
  Future<Spaces> getSpaces() async {
    var response = await _sendRequest('GET', '/api/smrt/contacts');
    Map responseBody = await _getJson(response.stream);
    return Spaces.fromJson(responseBody);
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

    switch (response.statusCode) {
      case 401:
        {
          throw InvalidAuthTokenException();
        }
        break;

      case 429:
        {
          throw TooManyRequestsException();
        }
        break;

      case 200:
        {
          return response;
        }
        break;

      default:
        {
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
