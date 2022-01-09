import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pronote_notification/pronote/session_http.dart';

class SessionHttpFake extends SessionHttp {
  
  int number = 1;
  
  @override
  Future<http.Response> get(String url) async {
    //debugPrint('Request GET ' + url);
    http.Response response = await _doFake('GET', url);
    return response;
  }

  @override
  Future<http.Response> post(String url, dynamic data) async {
    //debugPrint('Request POST ' + url + ' ' + (data?.toString() ?? ''));
    http.Response response = await _doFake('POST', url, data: data);
    return response;
  }
  
  Future<http.Response> _doFake(String method, String url, {dynamic data}) async {
    http.Request request = http.Request(method, Uri.parse(url));

    try {
      String requestBody = await rootBundle.loadString('assets/fakes/' + number.toString() + '_request.json');
      //debugPrint('Request wanted ' + method + ' ' + url + ' ' + requestBody);
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

  @override
  bool hasCookie() {
    return number > 1;
  }

  @override
  String? getCookie() {
    return hasCookie() ? 'cookie' : null;
  }
}