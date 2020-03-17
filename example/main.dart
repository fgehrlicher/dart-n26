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