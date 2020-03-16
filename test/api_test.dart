import 'dart:async';
import 'dart:io';

import 'package:dart_n26/api.dart';
import 'package:dart_n26/auth.dart';
import 'package:dart_n26/dart_n26.dart';
import 'package:dart_n26/exceptions.dart';
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
        Token.FromJson({
          'access_token': '123',
          'expires_in': 1000,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    var transactions = await subject.getTransactions(
        limit: 10,
        from: DateTime.now().subtract(Duration(days: 1)),
        to: DateTime.now());

    expect(4, transactions.length);
    expect('114 E-xpress Convenien', transactions[0].merchantName);
    expect(276, transactions[1].merchantCountryCode);
    expect(-27.5, transactions[2].originalAmount);
    expect('micro-v2-miscellaneous', transactions[3].category);
  });

  test('every request fails with invalid auth token', () async {
    var auth = AuthMock();
    var completer = Completer();

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', 200);
      }),
      auth,
    );

    expect(
      () async => await subject.getTransactions(),
      throwsA(TypeMatcher<InvalidAuthTokenException>()),
    );
  });

  test('every request fails with expired auth token', () async {
    var auth = AuthMock();
    var completer = Completer();

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', 200);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({
          'access_token': '123',
          'expires_in': 0,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    expect(
      () async => await subject.getTransactions(),
      throwsA(TypeMatcher<InvalidAuthTokenException>()),
    );
  });

  test('every request fails for unauthorized response', () async {
    var auth = AuthMock();
    var completer = Completer();

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', 401);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({
          'access_token': '123',
          'expires_in': 100,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    expect(
      () async => await subject.getTransactions(),
      throwsA(predicate((e) =>
          e is InvalidAuthTokenException &&
          e.toString() == 'Auth token invalid')),
    );
  });

  test('every request fails for invalid response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var statusCode = 500;

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', statusCode);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({
          'access_token': '123',
          'expires_in': 100,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    expect(
      () async => await subject.getTransactions(),
      throwsA(predicate((e) =>
          e is ApiException &&
          e.toString() == 'Unkown error. status code: $statusCode')),
    );
  });

  test('every request fails for empty byteStream', () async {
    var auth = AuthMock();
    var completer = Completer();
    var statusCode = 200;

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', statusCode);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({
          'access_token': '123',
          'expires_in': 100,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    expect(
      () async => await subject.getTransactions(),
      throwsA(predicate((e) =>
          e is Exception &&
          e.toString() == 'Exception: byteStream must not be empty')),
    );
  });

  test('every request fails for missing access_token', () async {
    var auth = AuthMock();
    var completer = Completer();
    var statusCode = 200;

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', statusCode);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({
          'expires_in': 100,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    expect(
      () async => await subject.getTransactions(),
      throwsA(predicate((e) =>
          e is InvalidAuthTokenException &&
          e.toString() == 'Auth token invalid')),
    );
  });

  test('every request fails for too many requests', () async {
    var auth = AuthMock();
    var completer = Completer();

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        return Response('', 429);
      }),
      auth,
    );

    when(auth.completeMfaChallenge(any)).thenAnswer(
      (_) => Future<Token>.value(
        Token.FromJson({
          'access_token': '123',
          'expires_in': 100,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    expect(
      () async => await subject.getTransactions(),
      throwsA(predicate((e) =>
          e is TooManyRequestsException &&
          e.toString() == 'Too Many Requests')),
    );
  });

  test('getProfile passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/profile.json');
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
        Token.FromJson({
          'access_token': '123',
          'expires_in': 1000,
        }),
      ),
    );
    await subject.authorize('', '', completer);

    var profile = await subject.getProfile();

    expect(827971200000, profile.birthDate);
    expect('+49xxxxxxxxxx', profile.mobilePhoneNumber);
  });
}
