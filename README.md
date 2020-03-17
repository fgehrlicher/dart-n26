# Dart N26 Api Client
[![pub package](https://img.shields.io/pub/v/dart_n26.svg)](https://pub.dev/packages/dart_n26) ![Tests](https://github.com/fgehrlicher/dart-n26/workflows/Tests/badge.svg) [![codecov](https://codecov.io/gh/fgehrlicher/dart-n26/branch/master/graph/badge.svg)](https://codecov.io/gh/fgehrlicher/dart-n26)  
Unofficial dart client for the N26 api. The purpose of this client is only to retrieve data, 
not to send payments or change settings.

## Authentication
To get a valid token from the API a 2-factor authentication is required. 
After calling the 'authorize' method, you will receive a pop-up message on your paired smartphone, 
which will ask you to tap to confirm that the sign in attempt is legitimate. confirm that and complete 
the completer passed to the authorize method. 

## Example Usage
```dart
import 'dart:async';
import 'package:http/http.dart';
import 'package:dart_n26/dart_n26.dart';

void main() async {
  // Replace these variables with your real credentials
  var email = 'YOUR N26 LOGIN EMAIL';
  var password = 'YOUR PASSWORD';

  var client = Client();
  var api = Api(client, Auth(client));

  var completer = Completer();
  completer.complete(Future.delayed(Duration(seconds: 20)));

  await api.authorize(email, password, completer);

  var transactions = await api.getTransactions(
    from: DateTime.now().subtract(Duration(days: 1)),
    to: DateTime.now(),
  );
  var profile = await api.getProfile();
  var accounts = await api.getAccounts();
  var statuses = await api.getStatuses();
  var addresses = await api.getAddresses();
  var cards = await api.getCards();
  var limits = await api.getLimits();
  var spaces = await api.getSpaces();
  var contacts = await api.getContacts();
  var statements = await api.getStatements();
  var statement = await api.getStatement(statements[0].id);
}
```
