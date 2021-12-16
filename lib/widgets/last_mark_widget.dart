import 'package:flutter/material.dart';
import 'package:pronote_notification/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastMarkWidget extends StatefulWidget {
  const LastMarkWidget({Key? key}) : super(key: key);

  @override
  State<LastMarkWidget> createState() => _LastMarkWidgetState();
}

class _LastMarkWidgetState extends State<LastMarkWidget> {
  bool checkInProgress = false;

  Future<String?> getLastMarksSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastMarksId');
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
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