import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pronote_notification/pronote/models/response/page_accueil.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:pronote_notification/settings_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:package_info_plus/package_info_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isLinux) {
    Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false
    );
    Workmanager().registerPeriodicTask("1", "checkNotes",
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        )
    );

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: selectNotification);
  }

  runApp(MyApp());
}

void selectNotification(String? payload) async {
  debugPrint('notification payload: $payload');
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "checkNotes") {
      await checkNewNote(forceShow: false);
    }
    
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  
  bool checkInProgress = false;
  
  Future<String?> getLastMarksSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastMarksId');
  }
  
  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return 'Version ' + packageInfo.version + ' - Build ' + packageInfo.buildNumber;
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pronote notification',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Pronote notification'),
          ),
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SettingsWidget(),
                  checkInProgress ? const Text('Vérification en cours ...') : TextButton(onPressed: () async {
                    checkInProgress = true;
                    await checkNewNote(forceShow: true);
                    checkInProgress = false;
                  }, child: const Text('Vérifier les notes')),
                  FutureBuilder<String?>(
                      future: getLastMarksSaved(),
                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text('Dernière note enregistrée : ' + snapshot.data!);
                        }

                        return Container();
                      }
                  ),
                  FutureBuilder<String>(
                    future: getVersionNumber(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data!);
                      }
                      
                      return Container();
                    }
                  ),
                ],
              )
          )
      ),
    );
  }
}

Future<void> checkNewNote({ forceShow = false }) async {
  final prefs = await SharedPreferences.getInstance();

  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? casUrl = prefs.getString('casUrl');
  String? pronoteUrl = prefs.getString('pronoteUrl');
  bool fake = prefs.getBool('fake') ?? false;
  bool check = prefs.getBool('check') ?? false;
  String? lastMarksId = prefs.getString('lastMarksId');
  
  if (!check) {
    print('Vérification désactivée');
    return;
  }
  
  if (username == null || password == null || casUrl == null || pronoteUrl == null) {
    throw Exception('Il manque des informations pour pouvoir se connecter !');
  }

  SessionPronote sessionPronote = SessionPronote(casUrl, pronoteUrl, useFake: fake);
  await sessionPronote.auth(username, password);

  Devoir? devoir = sessionPronote.homePage.notes?.listeDevoirs?.devoirs?.last;
  if (devoir != null && devoir.note?.valeur != null) {
    print('Dernière note : ' + devoir.toString());

    String devoirId = devoir.toString();

    sendNotificationDebug(devoirId);
    
    if (lastMarksId == devoirId && !forceShow) {
      print('Aucune nouvelle note');
      return;
    }
    
    if (!Platform.isLinux) {
      sendNotification(devoir);
    }
    
    prefs.setString('lastMarksId', devoirId);
  } else {
    print('Aucune note');
  }
}

Future<void> sendNotification(Devoir devoir) async {
  if (!Platform.isLinux) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'new_note', 'Nouvelle note',
        channelDescription: 'Lorsqu\'une nouvelle note arrive',
        importance: Importance.max,
        priority: Priority.max,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(Random().nextInt(9999), 'Nouvelle note !', devoir.toString(), platformChannelSpecifics, payload: null);
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