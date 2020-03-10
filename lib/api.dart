import 'dart:async';

import 'package:dart_n26/auth.dart';
import 'package:dart_n26/dto/dto.dart';
import 'package:http/http.dart';

class Api {
  final Client _client;
  Token _token;

  Api(this._client);

  /// Triggers the login process. After the future inside [mfaCompleter] is
  /// completed the auth controller will try to retrieve the token for the mfa
  /// token. If mfa is not done yet the process will fail.
  Future<void> authorize(
    String username,
    String password,
    Completer mfaCompleter,
  ) async {
    var auth = Auth(_client);

    var mfaToken = await auth.getMFAToken(username, password);
    await auth.triggerMFAChallenge(mfaToken);

    await mfaCompleter.future;
    _token = await auth.completeMfaChallenge(mfaToken);
  }
}
