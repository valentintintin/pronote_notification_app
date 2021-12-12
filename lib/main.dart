import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pronote_notification/pronote/models/response/page_accueil.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:pronote_notification/settings_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void startCallback() {
  FlutterForegroundTask.setTaskHandler(CheckNotesTaskHandler());
}

void updateService(String? lastMarks) {
  FlutterForegroundTask.updateService(
      notificationTitle: 'Vérification des notes en arrière plan',
      notificationText: lastMarks != null ? 'Dernière note : ' + lastMarks : 'Aucune note',
      callback: null);
}

class CheckNotesTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    updateService(await checkNewNote(forceShow: false));
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
  }

  @override
  void onButtonPressed(String id) {
    if (id == 'checkButton') {
      checkNewNote(forceShow: true);
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isLinux) {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: selectNotification);
  }

  runApp(const MyApp());
}

void selectNotification(String? payload) async {
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pronote notification',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const PageWidget()
    );
  }
}

class PageWidget extends StatefulWidget {
  const PageWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageWidgetState();
  }
}

class _PageWidgetState extends State<PageWidget> {
  bool checkInProgress = false;

  Future<String?> getLastMarksSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastMarksId');
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return 'Version ' + packageInfo.version + ' - Build ' + packageInfo.buildNumber;
  }

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'services_check_notes',
        channelName: 'Vérification des notes',
        channelDescription: 'Cette notification s\'affiche quand le service tourne en arrière plan',
        channelImportance: NotificationChannelImportance.NONE,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'checkButton', text: 'Vérifier maintenant'),
        ],
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 15 * 60 * 1000, // millis
        autoRunOnBoot: true,
        allowWifiLock: false,
      ),
      printDevLog: true,
    );
  }


  @override
  void initState() {
    _initForegroundTask();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Pronote notification'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    children: [
                      const Text('Application qui vous notifie lorsqu\'il y a une nouvelle note sur Pronote', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text('La vérification se fait toutes les 15 minutes.\nVos identifiants ne sont envoyés à personne, tout est fait sur votre téléphone :)'),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Card(
                            elevation: 10,
                            child: SettingsWidget()
                        ),
                      ),
                      Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text('Dernière note enregistrée', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: FutureBuilder<String?>(
                                      future: getLastMarksSaved(),
                                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                        return Text(snapshot.data ?? 'Aucune', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500));
                                      }
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: checkInProgress ? const Text('Vérification en cours ...') : OutlinedButton(
                                        onPressed: () async {
                                          setState(() {
                                            checkInProgress = true;
                                          });

                                          try {
                                            await checkNewNote(forceShow: true);
                                          } catch (e) {
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: false, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Erreur'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        Text(e.toString()),
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

                                          setState(() {
                                            checkInProgress = false;
                                          });
                                        }, child: const Text('Vérifier les notes maintenant')),
                                  ),
                                ),
                              ]
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: FutureBuilder<String>(
                                future: getVersionNumber(),
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data!);
                                  }

                                  return Container();
                                }
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: TextButton(onPressed: () async {
                              await launch('https://github.com/valentintintin/pronote_notification');
                            }, child: const Text('Accéder au code source')),
                          ),
                        ],
                      ),
                    ]
                ),
              ),
            )
        )
    );
  }
}

Future<String?> checkNewNote({ forceShow = false }) async {
  final prefs = await SharedPreferences.getInstance();

  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  String? casUrl = prefs.getString('casUrl');
  String? pronoteUrl = prefs.getString('pronoteUrl');
  bool fake = prefs.getBool('fake') ?? false;
  bool check = prefs.getBool('check') ?? false;
  String? lastMarksId = prefs.getString('lastMarksId');

  if (kDebugMode) {
    sendNotificationDebug('Coucou !');
  }

  if (!check && !forceShow) {
    print('Vérification désactivée');
    return null;
  }

  if (username == null || password == null || casUrl == null || pronoteUrl == null) {
    throw Exception('Il manque des informations pour pouvoir se connecter !');
  }

  SessionPronote sessionPronote = SessionPronote(casUrl, pronoteUrl, useFake: fake);
  await sessionPronote.auth(username, password);

  Devoir? devoir = sessionPronote.homePage.notes?.listeDevoirs?.devoirs?.last;
  if (devoir != null && devoir.note?.valeur != null) {
    String devoirId = devoir.toString();

    print('Dernière note : ' + devoirId);

    if (lastMarksId == devoirId && !forceShow) {
      print('Aucune nouvelle note');
    } else {
      if (!Platform.isLinux) {
        sendNotification(devoir, isCheck: forceShow);
      }

      prefs.setString('lastMarksId', devoirId);
    }

    if (!Platform.isLinux && await FlutterForegroundTask.isRunningService) {
      updateService(devoirId);
    }

    return devoirId;
  }

  print('Aucune note');

  if (!Platform.isLinux && await FlutterForegroundTask.isRunningService) {
    updateService(null);
  }

  return null;
}

Future<void> sendNotification(Devoir devoir, { isCheck = false }) async {
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