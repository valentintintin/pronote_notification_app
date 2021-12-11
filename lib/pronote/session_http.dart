import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SessionHttp {
  
  SessionHttp({ this.useFake = false });
  
  final bool useFake;
  int number = 1;
  
  Map<String, String> headers = {};

  Future<http.Response> get(String url) async {
    print('Request GET ' + url);
    http.Response response = await (useFake ? _doFake('GET', url) : http.get(Uri.parse(url), headers: headers));
    updateCookie(response);
    return response;
  }

  Future<http.Response> post(String url, dynamic data) async {
    print('Request POST ' + url + ' ' + (data?.toString() ?? ''));
    http.Response response = await (useFake ? _doFake('POST', url, data: data) : http.post(Uri.parse(url), body: data, headers: headers));
    updateCookie(response);
    return response;
  }
  
  Future<http.Response> _doFake(String method, String url, {dynamic data}) async {
    http.Request request = http.Request(method, Uri.parse(url));

    try {
      String requestBody = await rootBundle.loadString('assets/fakes/' + number.toString() + '_request.json');
      print('Request wanted ' + method + ' ' + url + ' ' + requestBody);
    } catch (e) {
      // ignored
    }
    
    try {
      ByteData fileBody = await rootBundle.load('assets/fakes/' + (number++).toString() + '.txt');
      
      return http.Response.bytes(fileBody.buffer.asInt8List(), 200, request: request);
    } catch (e) {
      print(e.toString());
      return http.Response(e.toString(), 500, request: request); 
    }
  }

  void updateCookie(http.Response response) {
    print('Response ' + response.request.toString() + ' ' + response.statusCode.toString() + ' ' + (response.body.length > 1000 ? response.body.substring(0, 1000) : response.body));
    
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';'); 
      
      String cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      
      if (cookie.contains('""')) {
        return;
      }
      
      print('COOKIE : ' + response.request.toString() + ' ' + cookie);

      headers['cookie'] = cookie;
    }
    
    print('');
  }
  
  bool hasCookie() {
    return headers.containsKey('cookie');
  }
}