import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
StreamController<SessionPronote> controller = StreamController<SessionPronote>();
Stream stremPronoteSession = controller.stream;

Future<SessionPronote> authPronote() async {
  final prefs = await SharedPreferences.getInstance();

  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? casUrl = prefs.getString('casUrl');
  String? pronoteUrl = prefs.getString('pronoteUrl');
  bool fake = prefs.getBool('fake') ?? false;

  if (kDebugMode) {
    sendNotificationDebug('Coucou !');
  }

  if (username == null || password == null || casUrl == null || pronoteUrl == null) {
    throw Exception('Il manque des informations pour pouvoir se connecter !');
  }

  SessionPronote sessionPronote = SessionPronote(casUrl, pronoteUrl, useFake: fake);
  await sessionPronote.auth(username, password);

  controller.add(sessionPronote);
  
  return sessionPronote;
}

Future<Exam?> checkNewNote({ forceShow = false }) async {
  final prefs = await SharedPreferences.getInstance();
  bool check = prefs.getBool('check') ?? false;

  if (!check && !forceShow) {
    print('Vérification désactivée');
    return null;
  }

  SessionPronote sessionPronote = await authPronote();

  Exam? lastMark = sessionPronote.getLastMark();
  if (lastMark != null) {
    String lastMarkId = lastMark.toString();

    String? lastMarksId = prefs.getString('lastMarksId');

    if (lastMarksId != lastMarkId || forceShow){
      if (!Platform.isLinux) {
        sendNotification(lastMark, isCheck: forceShow);
      }

      prefs.setString('lastMarksId', lastMarkId);
    }

    return lastMark;
  }

  return null;
}

Future<void> sendNotification(Exam devoir, { isCheck = false }) async {
  if (!Platform.isLinux) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'new_note', 'Nouvelle note',
      channelDescription: 'Lorsqu\'une nouvelle note arrive',
      importance: Importance.max,
      priority: Priority.max,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(Random().nextInt(9999), isCheck ? 'Dernière note' : 'Nouvelle note !', devoir.toString(), platformChannelSpecifics, payload: null);
  }
}

Future<void> sendNotificationDebug(String content) async {
  if (!Platform.isLinux) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'debug', 'Debug',
      channelDescription: 'Pour débugger',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Debug', content, platformChannelSpecifics, payload: null);
  }
}

void showOkDialog(BuildContext context, String title, String message) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}