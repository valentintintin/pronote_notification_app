import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pronote_notification/service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPronotePageWidget extends StatelessWidget {
  WebViewPronotePageWidget({Key? key}) : super(key: key);

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  Widget build(BuildContext context) {    
    return Scaffold(
        appBar: AppBar(
          title: const Text("Site Pronote"),
        ),
        body: FutureBuilder(
            future: getAuthCasRequest(),
            builder: (BuildContext context, AsyncSnapshot<Map<String?, String?>> sessionPronoteSnapshot) {
              if (sessionPronoteSnapshot.hasData) {
                if (sessionPronoteSnapshot.hasError) {
                  showOkDialog(context, 'Erreur accès Pronote', sessionPronoteSnapshot.error.toString());
                  Navigator.of(context).pop();
                }
                
                String urlCas = sessionPronoteSnapshot.data!['urlPost']!;
                String urlPronote = sessionPronoteSnapshot.data!['urlPronote']!;
                sessionPronoteSnapshot.data!.remove('urlPost');
                sessionPronoteSnapshot.data!.remove('urlPronote');
                
                debugPrint('Direction ' + urlCas);
                
                List<String> parts = [];
                sessionPronoteSnapshot.data!.forEach((key, value) {
                  parts.add('${Uri.encodeQueryComponent(key!)}=${Uri.encodeQueryComponent(value!)}');
                });

                _controller.future.then((controller) async {
                  await controller.loadRequest(WebViewRequest(
                    method: WebViewRequestMethod.post,
                    uri: Uri.parse(urlCas),
                    body: Uint8List.fromList(utf8.encode(parts.join('&'))),
                    headers: { 'content-type': 'application/x-www-form-urlencoded' }
                  ));

                  await controller.loadUrl(urlPronote);
                });

                return WebView(
                  debuggingEnabled: true,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) async {
                    _controller.complete(controller);
                  }
                );
              }

              return Center(
                  child: Column(
                      children: const [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Connexion en cours'),
                        )
                      ]
                  )
              );
            }
        )
    );
  }
}