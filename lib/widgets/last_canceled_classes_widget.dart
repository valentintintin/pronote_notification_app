import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pronote_notification/service.dart';

class LastCanceledClassesWidget extends StatefulWidget {
  const LastCanceledClassesWidget({Key? key}) : super(key: key);

  @override
  State<LastCanceledClassesWidget> createState() => _LastCanceledClassesWidgetState();
}

class _LastCanceledClassesWidgetState extends State<LastCanceledClassesWidget> {
  bool checkInProgress = false;

  StreamSubscription? streamSubscription;

  String? lastCanceledClasses;
  String? lastCheckDate;

  @override
  void initState() {
    streamSubscription = streamPronoteSession.listen((session) async {
      lastCanceledClasses = prefs.getString('lastCanceledClassesId');
      lastCheckDate = prefs.getString('lastCheckDate');

      setState(() {});
    });

    lastCanceledClasses = prefs.getString('lastCanceledClassesId');
    lastCheckDate = prefs.getString('lastCheckDate');
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text('Derniers cours annulés enregistrés' + (lastCheckDate != null ? '\n' + lastCheckDate! : ''), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(lastCanceledClasses ?? 'Aucun', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
              ),
              Center(
                widthFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: checkInProgress ? const Text('Vérification en cours ...') : OutlinedButton(
                      onPressed: () async {
                        setState(() {
                          checkInProgress = true;
                        });

                        try {
                          await checkNewMark(force: true);
                        } catch (e) {
                          showOkDialog(context, "Erreur", e.toString());
                        }
                        
                        setState(() {
                          checkInProgress = false;
                        });
                      }, child: const Text('Vérifier les cours annulées maintenant')),
                ),
              ),
            ]
        ),
      ),
    );
  }
}