import 'package:flutter/cupertino.dart';
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
    
    for (int i = 0; i < 3; i++) {
      debugPrint('Use fake request ' + number.toString() + ' for ' + url);

      try {
        ByteData fileBody = await rootBundle.load('assets/fakes/' + number.toString() + '.txt');
        return http.Response.bytes(fileBody.buffer.asInt8List(), 200, request: request);
      } 
      catch (e) {
        // ignored
      }
      finally {
        number++;
      }
    }
    
    return http.Response('No fake response found', 500, request: request);
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