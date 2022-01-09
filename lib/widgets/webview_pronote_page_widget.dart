import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pronote_notification/service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPronotePageWidget extends StatefulWidget {
  WebViewPronotePageWidget({Key? key}) : super(key: key);

  @override
  State<WebViewPronotePageWidget> createState() => _WebViewPronotePageWidgetState();
}

class _WebViewPronotePageWidgetState extends State<WebViewPronotePageWidget> {
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

                List<String> parts = [];
                sessionPronoteSnapshot.data!.forEach((key, value) {
                  parts.add('${Uri.encodeQueryComponent(key!)}=${Uri.encodeQueryComponent(value!)}');
                });

                bool isFirstPage = true;
                late WebViewController _controller;

                WebView webview = WebView(
                  debuggingEnabled: true,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) async {
                    _controller = controller;

                    await controller.loadRequest(WebViewRequest(
                        method: WebViewRequestMethod.post,
                        uri: Uri.parse(urlCas),
                        body: Uint8List.fromList(utf8.encode(parts.join('&'))),
                        headers: { 'content-type': 'application/x-www-form-urlencoded' }
                    ));
                  },
                  onPageStarted: (url) {
                    debugPrint('WebView start ' + url);
                  },
                  onPageFinished: (url) {
                    debugPrint('WebView finish ' + url + ' ' + isFirstPage.toString());

                    if (isFirstPage) {
                      _controller.loadUrl(urlPronote);
                      isFirstPage = false;
                    }
                  }
                );
                
                return /*isFirstPage ? Center(
                    child: Column(
                        children: [
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Connexion à Pronote en cours. 2/2'),
                          ),
                          SizedBox(child: webview, width: 1, height: 1,)
                        ]
                    )
                ) : */webview;
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
                          child: Text('Connexion à l\'académie en cours. 1/2'),
                        )
                      ]
                  )
              );
            }
        )
    );
  }
}