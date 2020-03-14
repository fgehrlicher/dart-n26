import 'dart:async';

import 'package:dart_n26/api.dart';
import 'package:dart_n26/auth.dart';
import 'package:dart_n26/dart_n26.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

class AuthMock extends Mock implements Auth {}

void main() {
  test('authorize calls the right auth methods', () async {
    var client = Client();
    var auth = AuthMock();
    var subject = Api(client, auth);
    var testUser = 'testusername';
    var testPassword = 'testpassword';
    var testCompleter = Completer();
    var testMfaToken = 'testtoken';

    when(auth.getMFAToken(testUser, testPassword))
        .thenAnswer((_) async => Future<String>.value(testMfaToken));

    unawaited(subject.authorize(testUser, testPassword, testCompleter));

    await untilCalled(auth.getMFAToken(any, any));
    verify(auth.getMFAToken(testUser, testPassword)).called(1);
    await untilCalled(auth.triggerMFAChallenge(any));
    verify(auth.triggerMFAChallenge(testMfaToken)).called(1);
    verifyNoMoreInteractions(auth);
    testCompleter.complete();

    await untilCalled(auth.completeMfaChallenge(any));
    verify(auth.completeMfaChallenge(testMfaToken)).called(1);
    verifyNoMoreInteractions(auth);
  });

  test('authorize calls the right auth methods', () async {
    var auth = AuthMock();
    var completer = Completer();
    completer.complete();

    var subject = Api(
      MockClient(),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
          (_) => Future<Token>.value(
        Token.FromJson({'access_token': '123'}),
      ),
    );

    var test = await subject.getTransactions();

    expect(test, "matcher");
  });
}
