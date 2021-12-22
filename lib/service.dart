import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:pronote_notification/pronote/models/response/agenda_page.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
StreamController<SessionPronote?> streamPronoteSessionController = StreamController<SessionPronote?>();
Stream<SessionPronote?> streamPronoteSession = streamPronoteSessionController.stream.asBroadcastStream();
SessionPronote? lastSessionPronote;

late SharedPreferences prefs;

Future<bool> checkNetwork() async {
  if (!Platform.isLinux) {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Aucun réseau');
    }
  }
  
  return true;
}

Future<Map<String?, String?>> getAuthCasRequest() async {
  checkNetwork();
  
  prefs = await SharedPreferences.getInstance();

  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? casUrl = prefs.getString('casUrl');
  String? pronoteUrl = prefs.getString('pronoteUrl');
  bool fake = prefs.getBool('fake') ?? false;

  if (username == null || password == null || casUrl == null || pronoteUrl == null) {
    throw Exception('Il manque des informations pour pouvoir se connecter !');
  }

  SessionPronote sessionPronote = SessionPronote(casUrl, pronoteUrl, useFake: fake);
  return sessionPronote.getAuthCasRequest(username, password);
}

Future<SessionPronote> authPronote({ forceAuth = false }) async {
  checkNetwork();

  if (!forceAuth && lastSessionPronote != null) {
    return lastSessionPronote!;
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

void runAlarm() {
  checkNetwork();
  
  for (int i = 0; i < 3; i++) {
    try {
      checkNewMark(forceAuth: true);
      checkNewCanceledClasses(forceAuth: false);
      break; // exit loop
    }
    on ClientException catch (e) {
      print('Erreur : ' + e.toString());
      // continue
    }
    catch (e) {
      sendNotificationError(e.toString());
      rethrow;
    }
  }
}

Future<ExamsList?> checkNewMark({ notify = true, force = false, forceAuth = false }) async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  
  print('Vérification des notes');
  
  bool check = prefs.getBool('check') ?? false;

  if (!check && !force) {
    print('Vérification désactivée');
    return null;
  }

  checkNetwork();

  ExamsList? lastMarks = await (await authPronote(forceAuth: forceAuth)).getLastsMark();
  
  prefs.setString('lastCheckDate', DateTime.now().toString());

  if (lastMarks != null) {
    String lastMarksId = lastMarks.toString();
    String? lastMarksIdSaved = prefs.getString('lastMarksId');
    
    for (var mark in lastMarks.exams!.reversed.toList()) { // on reverse pour que la dernière notification soit en premier
      String markId = mark.toString();
      
      if (lastMarksIdSaved == null || !lastMarksIdSaved.contains(markId)) {
        print('Nouvelle note ' + markId);

        if (!Platform.isLinux && notify) {
          sendNotificationMarks(markId, isCheck: force);
        }
      }
    }

    prefs.setString('lastMarksId', lastMarksId);
  } else {
    print('Pas de note');
    prefs.remove('lastMarksId');
  }

  streamPronoteSessionController.add(lastSessionPronote);

  return lastMarks;
}

Future<List<Class>?> checkNewCanceledClasses({ notify = true, force = false, forceAuth = false }) async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  
  print('Vérification des cours annulés');
  
  bool check = prefs.getBool('check') ?? false;

  if (!check && !force) {
    print('Vérification désactivée');
    return null;
  }

  checkNetwork();

  List<Class>? lastCanceledClasses = await (await authPronote(forceAuth: forceAuth)).getLastCanceledClasses();
  
  prefs.setString('lastCheckDate', DateTime.now().toString());

  if (lastCanceledClasses != null) {
    String lastCanceledClassesId = lastCanceledClasses.map((e) => e.toString()).join('\n').toString();
    String? lastCanceledClassesIdSaved = prefs.getString('lastCanceledClassesId');
    
    for (var classe in lastCanceledClasses.reversed.toList()) { // on reverse pour que la dernière notification soit en premier
      String classeId = classe.toString();
      
      if (lastCanceledClassesIdSaved == null || !lastCanceledClassesIdSaved.contains(classeId)) {
        print('Nouveau cours annulé ' + classeId);

        if (!Platform.isLinux && notify) {
          sendNotificationCanceledClasses(classeId, isCheck: force);
        }
      }
    }

    prefs.setString('lastCanceledClassesId', lastCanceledClassesId);
  } else {
    print('Pas de cours annulé');
    prefs.remove('lastCanceledClassesId');
  }

  streamPronoteSessionController.add(lastSessionPronote);

  return lastCanceledClasses;
}

Future<void> sendNotificationCanceledClasses(String classes, { isCheck = false }) async {
  if (!Platform.isLinux) {
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'new_canceled_class', 'Nouveau cours annulé',
      channelDescription: 'Lorsqu\'un nouveau cours est anuulé',
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      setAsGroupSummary: true
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(Random().nextInt(pow(2, 31).round()), isCheck ? 'Derniers cours annulés' : 'Nouveau cours annulé !', classes, platformChannelSpecifics, payload: null);
  }
}

Future<void> sendNotificationMarks(String marks, { isCheck = false }) async {
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

Future<void> sendNotificationError(String errorMessage) async {
  print('Erreur : ' + errorMessage);
  
  if (!Platform.isLinux) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'error', 'Erreur',
      channelDescription: 'Quand il y a une erreur dans la vérification',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(1, 'Erreur pendant la vérification sur Pronote', errorMessage, platformChannelSpecifics, payload: null);
  }
}

void showOkDialog(BuildContext context, String title, String message) {
  print(title+ ' ' + message);
  
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