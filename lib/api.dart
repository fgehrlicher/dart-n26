import 'dart:async';
import 'dart:convert';

import 'package:dart_n26/auth.dart';
import 'package:dart_n26/dto/dto.dart';
import 'package:http/http.dart' as http;

class Api {
  final http.Client _client;
  final Auth _auth;

  Token _token;

  Api(this._client, this._auth);

  /// Triggers the login process. After the future inside [mfaCompleter] is
  /// completed the auth controller will try to retrieve the token for the mfa
  /// token. If mfa is not done yet the process will fail.
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

    var uri = Uri.https(
      'api.tech26.de',
      '/api/smrt/transactions',
      queryParameters,
    );

    var request = http.Request(
      'GET',
      uri,
    )..headers['Authorization'] = 'Bearer ${_token.accessToken}';

    var response = await _client.send(request);

    var rawContent = await response.stream.bytesToString();

    var transactions = (jsonDecode(rawContent) as List)
        .map((e) => Transaction.fromJson(e))
        .toList();

    return transactions;
  }
}
