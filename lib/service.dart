import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
StreamController<SessionPronote?> streamPronoteSessionController = StreamController<SessionPronote?>();
Stream<SessionPronote?> streamPronoteSession = streamPronoteSessionController.stream.asBroadcastStream();
SessionPronote? lastSessionPronote;

late SharedPreferences prefs;

Future<SessionPronote> authPronote() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('Aucun réseau');
  }
  
  prefs = await SharedPreferences.getInstance();

  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? casUrl = prefs.getString('casUrl');
  String? pronoteUrl = prefs.getString('pronoteUrl');
  bool fake = prefs.getBool('fake') ?? false;

  if (username == null || password == null || casUrl == null || pronoteUrl == null) {
    throw Exception('Il manque des informations pour pouvoir se connecter !');
  }

  lastSessionPronote = SessionPronote(casUrl, pronoteUrl, useFake: fake);
  await lastSessionPronote!.auth(username, password);

  streamPronoteSessionController.add(lastSessionPronote);
  
  return lastSessionPronote!;
}

Future<String?> checkNewMark({ forceShow = false }) async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  
  print('Vérification des notes');
  
  bool check = prefs.getBool('check') ?? false;

  if (!check && !forceShow) {
    print('Vérification désactivée');
    return null;
  }

  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('Aucun réseau');
  }

  bool shouldRefresh = lastSessionPronote != null;

  if (kDebugMode) {
    sendNotificationDebug(shouldRefresh.toString());
  }
  
  SessionPronote sessionPronote = lastSessionPronote ?? await authPronote();

  ExamsList? lastMarks = await sessionPronote.getLastsMark(refresh: shouldRefresh);
  
  streamPronoteSessionController.add(lastSessionPronote);
  
  if (lastMarks != null) {
    String? lastMarksIdSaved = prefs.getString('lastMarksId');
    
    String lastMarksId = lastMarks.toString();
    
    for (var mark in lastMarks.exams!.reversed.toList()) { // on reverse pour que la dernière notification soit en premier
      String markId = mark.toString();
      
      if (lastMarksIdSaved == null || !lastMarksIdSaved.contains(markId)) {
        print('Nouvelle note ' + markId);

        if (!Platform.isLinux) {
          sendNotification(markId, isCheck: forceShow);
        }
      }
    }

    prefs.setString('lastMarksId', lastMarksId);

    return lastMarksId;
  }
  
  print('Pas de note');

  return null;
}

Future<void> sendNotification(String marks, { isCheck = false }) async {
  if (!Platform.isLinux) {
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'new_note', 'Nouvelle note',
      channelDescription: 'Lorsqu\'une nouvelle note arrive',
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      setAsGroupSummary: true
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(Random().nextInt(pow(2, 31).round()), isCheck ? 'Dernière note' : 'Nouvelle note !', marks, platformChannelSpecifics, payload: null);
  }
}

Future<void> sendNotificationDebug(String content) async {
  if (!Platform.isLinux) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'debug', 'Debug',
      channelDescription: 'Pour débugger',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Debug', 'Débug : ' + content, platformChannelSpecifics, payload: null);
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