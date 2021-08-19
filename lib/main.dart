import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flight_local/home_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  final HttpLink httpLink = HttpLink('https://b2c-api.flightlocal.com/graphql');
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(link: httpLink, cache: GraphQLCache(store: InMemoryStore())),
  );

  var app = GraphQLProvider(
    client: client,
    child: MyApp(),
  );
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flight Local',
      theme: ThemeData(
        primaryColor: Color(0xff00276c),
        hintColor: Color(0xffffc610),
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
