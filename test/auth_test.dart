import 'dart:convert';

import 'package:dart_n26/auth.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('getMFAToken returns the correct mfa token', () async {
    var testUser = 'testusername';
    var testPassword = 'testpassword';
    var testMfaToken = 'testmfatoken';

    var subject = Auth(
      MockClient((request) async {
        var jsonMap = {'mfaToken': testMfaToken};
        return http.Response(
          json.encode(jsonMap),
          403,
        );
      }),
    );

    var token = await subject.getMFAToken(testUser, testPassword);
    expect(token, testMfaToken);
  });

  test('getMFAToken throws an exception if response is empty', () async {
    var subject = Auth(
      MockClient((request) async {
        return http.Response('', 403);
      }),
    );

    expect(
      () async => await subject.getMFAToken('', ''),
      throwsA(TypeMatcher<Exception>()),
    );
  });

  test(
      'getMFAToken throws an generic exception if the response code is not 400 or 403',
      () async {
    var subject = Auth(
      MockClient((request) async {
        return http.Response('', 234);
      }),
    );

    expect(
      () async => await subject.getMFAToken('', ''),
      throwsA(TypeMatcher<AuthApiException>()),
    );
  });

  test(
      'getMFAToken throws a invalid credential exception if the response code is not 400',
      () async {
    var subject = Auth(
      MockClient((request) async {
        return http.Response('', 400);
      }),
    );

    expect(
      () async => await subject.getMFAToken('', ''),
      throwsA(TypeMatcher<InvalidCredentialsException>()),
    );
  });

  test(
      'getMFAToken throws a invalid credential exception if the response does not contain a mfa token',
      () async {
    var testMfaToken = 'testmfatoken';
    var testUser = 'testusername';
    var testPassword = 'testpassword';

    var subject = Auth(
      MockClient((request) async {
        var jsonMap = {'mfaToken2': testMfaToken};
        return http.Response(
          json.encode(jsonMap),
          403,
        );
      }),
    );

    expect(
      () async => await subject.getMFAToken(testUser, testPassword),
      throwsA(TypeMatcher<NoMfaTokenException>()),
    );
  });

  test('triggerMFAChallenge returns nothing on success', () async {
    var subject = Auth(
      MockClient((request) async {
        return http.Response('', 201);
      }),
    );

    await subject.triggerMFAChallenge('dummyToken');
  });

  test(
      'triggerMFAChallenge throws a mfa trigger exception if the response does not return 201',
      () async {
    var subject = Auth(
      MockClient((request) async {
        return http.Response('', 400);
      }),
    );

    expect(
      () async => await subject.triggerMFAChallenge('dummyToken'),
      throwsA(TypeMatcher<MfaTriggerException>()),
    );
  });

  test('completeMfaChallenge returns the correct token', () async {
    var testMfaToken = 'testmfatoken';
    var testAccessToken = 'testaccesstoken';
    var testRefreshToken = 'testrefreshtoken';
    var testTokenType = 'testtokentype';
    var testExpiresIn = 100;

    var subject = Auth(
      MockClient((request) async {
        var jsonMap = {
          'access_token': testAccessToken,
          'refresh_token': testRefreshToken,
          'token_type': testTokenType,
          'expires_in': testExpiresIn,
        };

        return http.Response(
          json.encode(jsonMap),
          200,
        );
      }),
    );

    var token = await subject.completeMfaChallenge(testMfaToken);
    expect(token.refreshToken, testRefreshToken);
    expect(token.accessToken, testAccessToken);
    expect(token.tokenType, testTokenType);
  });

  test(
      'completeMfaChallenge throws a MfaNotCompletedException if the response does not return 200',
          () async {
        var subject = Auth(
          MockClient((request) async {
            return http.Response('', 400);
          }),
        );

        expect(
              () async => await subject.completeMfaChallenge('dummyToken'),
          throwsA(TypeMatcher<MfaNotCompletedException>()),
        );
      });
}
