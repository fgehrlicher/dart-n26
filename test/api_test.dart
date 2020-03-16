import 'dart:async';
import 'dart:io';

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

  test('getTransactions passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/transactions.json');
    var fixtureContent = await fixture.readAsString();

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response(fixtureContent, 200);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({'access_token': '123'}),
      ),
    );
    await subject.authorize('', '', completer);

    var transactions = await subject.getTransactions();
    expect(4, transactions.length);
    expect('114 E-xpress Convenien', transactions[0].merchantName);
    expect(276, transactions[1].merchantCountryCode);
    expect(-27.5, transactions[2].originalAmount);
    expect('micro-v2-miscellaneous', transactions[3].category);
  });
}
