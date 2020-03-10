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

  test('getMFAToken throws an exception if the response code is not 403', () async {
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
}
