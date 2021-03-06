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

  test('getAccounts passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/accounts.json');
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

    var accounts = await subject.getAccounts();

    expect('OWNER', accounts.users[0].userRole);
    expect('XXX', accounts.externalId.iban);
    expect('N26 Bank', accounts.bankName);
    expect(731.66, accounts.bankBalance);
    expect(null, accounts.physicalBalance);
  });

  test('getStatuses passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/statuses.json');
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

    var statuses = await subject.getStatuses();

    expect('COMPLETED', statuses.kycDetails.status);
    expect(1541440294844, statuses.kycInitiated);
    expect(null, statuses.userStatusCol);
  });

  test('getAddresses passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/addresses.json');
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

    var addresses = await subject.getAddresses();

    expect('SHIPPING', addresses.addresses[0].type);
    expect('PASSPORT', addresses.addresses[1].type);
    expect('LEGAL', addresses.addresses[2].type);
    expect(3, addresses.paging.totalResults);
  });

  test('getCards passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/cards.json');
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

    var cards = await subject.getCards();

    expect('STANDARD', cards[0].cardProductType);
    expect(1727654400000, cards[0].expirationDate);
    expect('MASTERCARD', cards[0].cardType);
    expect(null, cards[0].publicToken);
  });

  test('getLimits passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/limits.json');
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

    var limits = await subject.getLimits();

    expect('POS_DAILY_ACCOUNT', limits[0].limit);
    expect(2500.0, limits[0].amount);
    expect('ATM_DAILY_ACCOUNT', limits[1].limit);
    expect(2500.0, limits[1].amount);
  });

  test('getContacts passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/contacts.json');
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

    var contacts = await subject.getContacts();

    expect('sepa', contacts[0].account.accountType);
    expect('XXX', contacts[0].subtitle);
    expect('sepa2', contacts[1].account.accountType);
    expect('XXX', contacts[1].subtitle);
  });

  test('getSpaces passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/spaces.json');
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

    var spaces = await subject.getSpaces();

    expect('https://cdn.number26.de/spaces/default-images/account_cards.jpg?version=1', spaces.spaces[0].imageUrl);
    expect(685.77, spaces.totalBalance);
    expect(0, spaces.userFeatures.availableSpaces);
  });

  test('getStatements passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixture = File('test_fixtures/statements.json');
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

    var statements = await subject.getStatements();

    expect('statement-2020-03', statements[0].id);
    expect(1580515200000, statements[1].visibleTS);
    expect(1, statements[2].month);
  });

  test('getStatement passes and decodes the http client response', () async {
    var auth = AuthMock();
    var completer = Completer();
    var fixtureContent = 'PDF CONTENT';
    var statementId = 'statement_id';

    completer.complete();
    var subject = Api(
      MockClient((request) async {
        if (request.url.path == '/api/statements/$statementId') {
          return Response(fixtureContent, 200);
        }
        return Response('', 404);
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

    var statement = await subject.getStatement(statementId);
    var string = await statement.bytesToString();

    expect(fixtureContent, string);
  });
}
