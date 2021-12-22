import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class SessionHttp {
  
  Map<String, String> headers = {};

  Future<http.Response> get(String url) async {
    //debugPrint('Request GET ' + url);
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    updateCookie(response);
    return response;
  }

  Future<http.Response> post(String url, dynamic data) async {
    //debugPrint('Request POST ' + url + ' ' + (data?.toString() ?? ''));
    http.Response response = await http.post(Uri.parse(url), body: data, headers: headers);
    updateCookie(response);
    return response;
  }
  
  void updateCookie(http.Response response) {
    //debugPrint('Response ' + response.request.toString() + ' ' + response.statusCode.toString() + ' ' + (response.body.length > 1000 ? response.body.substring(0, 1000) : response.body));
    
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null && rawCookie.contains('TGC')) {
      int index = rawCookie.indexOf(';'); 
      
      String cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      
      if (cookie.contains('""')) {
        return;
      }
      
      //debugPrint('COOKIE : ' + response.request.toString() + ' ' + cookie);

      headers['cookie'] = cookie;
    }
    
    //debugPrint('');
  }
  
  bool hasCookie() {
    return headers.containsKey('cookie') && headers['cookie'] != null;
  }
  
  String? getCookie() {
    return hasCookie() ? headers['cookie'] : null;
  }
}