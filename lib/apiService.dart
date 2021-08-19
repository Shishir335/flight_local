import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  // http request with the query for filtering with authentication
  Future<dynamic> getPackages(String token, var query) async {
    var result = await http.get(
        Uri.parse('https://b2c-api.flightlocal.com/graphql?query=$query'),
        headers: {HttpHeaders.authorizationHeader: token});

    print(result.body);
//decoding the http response to json
    var res = jsonDecode(result.body);
    return res;
  }
}
