import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pronote_notification/service.dart';

class LastMarksWidget extends StatefulWidget {
  const LastMarksWidget({Key? key}) : super(key: key);

  @override
  State<LastMarksWidget> createState() => _LastMarksWidgetState();
}

class _LastMarksWidgetState extends State<LastMarksWidget> {
  bool checkInProgress = false;

  StreamSubscription? streamSubscription;

  String? lastMark;

  @override
  void initState() {
    streamSubscription = streamPronoteSession.listen((session) async {
      lastMark = (await session?.getLastsMark()).toString();
      setState(() {});
    });

    lastMark = prefs.getString('lastMarksId');
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
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text('Dernière notes enregistrées', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(lastMark ?? 'Aucune', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
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
                          await checkNewMark(forceShow: true);
                        } catch (e) {
                          showOkDialog(context, "Erreur", e.toString());
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
    );
  }
}