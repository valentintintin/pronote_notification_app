import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pronote_notification/service.dart';
import 'package:pronote_notification/widgets/webview_pronote_page_widget.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem<String>> pronoteUrls = {
    'Établissement *': '',
    'Collège Fernand Bouvier - Saint Jean de Bournay': 'https://0382265f.index-education.net/pronote/',
    'Lycée Léonard de Vinci - Villefontaine': 'https://0382440w.index-education.net/pronote/',
  }.entries.map((e) => DropdownMenuItem(
    child: Text(e.key),
    value: e.value,
  )).toList();

  final List<DropdownMenuItem<String>> casUrls = [
    'https://cas.ent.auvergnerhonealpes.fr/login?selection=GRE-ATS_parent_eleve&submit=Valider'
  ].map((e) => DropdownMenuItem(
    child: Text('URL login : ' + e),
    value: e,
  )).toList();

  bool firstLoadSharedPreferencies = true;
  bool loadingInProgress = false;

  String? username;
  String? password;
  String? casUrl;
  String? pronoteUrl;
  int interval = 15;
  bool check = true;

  @override
  void initState() {
    username = prefs.getString('username');
    password = prefs.getString('password');
    casUrl = prefs.getString('casUrl') ?? casUrls.first.value;
    pronoteUrl = prefs.getString('pronoteUrl') ?? pronoteUrls.first.value;
    interval = prefs.getInt('interval') ?? interval;
    check = prefs.getBool('check') ?? true;
    
    if (check) {
      checkBatteryOptimisationDisabled();
    }
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
                    child: Text('Vos informations', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  icon: Icon(Icons.person),
                                  labelText: 'Identifiant *',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                initialValue: username,
                                onSaved: (value) => username = value?.toLowerCase(),
                                validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Votre identifiant est requis'
                                    : null
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    icon: Icon(Icons.security),
                                    labelText: 'Mot de passe *',
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  initialValue: password,
                                  onSaved: (value) => password = value,
                                  validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Votre mot de passe est requis'
                                      : null
                              )
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child:
                              DropdownButtonFormField(
                                  isExpanded: true,
                                  iconSize: 24,
                                  elevation: 16,
                                  icon: const Icon(Icons.arrow_downward),
                                  onChanged: (newValue) {},
                                  onSaved: (value) => pronoteUrl = value.toString(),
                                  value: pronoteUrl,
                                  items: pronoteUrls,
                                  validator: (value) =>
                                  value == null || value == ''
                                      ? 'Votre établissement est requis'
                                      : null
                              )
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Intervalle de vérification\n' + interval.toString() + ' minutes'),
                                    Expanded(
                                        child: Slider(
                                          value: interval.roundToDouble(),
                                          min: kDebugMode ? 1 : 15,
                                          max: 4 * 60,
                                          divisions: 15,
                                          label: interval.round().toString() + ' minutes',
                                          onChanged: (double value) {
                                            setState(() {
                                              interval = value.round();
                                            });
                                          },
                                        )
                                    )
                                  ]
                              )
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Activer la vérification des nouvelles notes'),
                                    Checkbox(
                                      value: check,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          check = value!;
                                        });
                                      },
                                    )
                                  ]
                              )
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              loadingInProgress ? const Text('Connexion en cours ...') : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _authPronote(false);
                                    },
                                    child: const Text('Enregistrer'),
                                  )
                              ),
                              loadingInProgress ? const SizedBox() : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => WebViewPronotePageWidget()),
                                        );
                                      }, child: const Text('Ouvrir Pronote'))
                              ),
                              kDebugMode ? loadingInProgress ? const Text('Connexion en cours ...') : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      _authPronote(true);
                                    },
                                    child: const Text('Tester (fake)'),
                                  )
                              ) : Container(),
                              kDebugMode ? Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await prefs.remove('lastMarksId');
                                      await prefs.remove('lastCanceledClassesId');
                                      await prefs.remove('lastCheckDate');

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Ok')),
                                      );
                                    },
                                    child: const Text('Reset'),
                                  )
                              ) : Container(),
                              kDebugMode ? Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await runAlarm();
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Ok')),
                                      );
                                    },
                                    child: const Text('Run alarm'),
                                  )
                              ) : Container(),
                            ],
                          )
                        ],
                      )
                  )
                ]
            )
        )
    );
  }

  Future<void> _authPronote(bool fake) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      prefs.setString('username', username!);
      prefs.setString('password', password!);
      prefs.setString('casUrl', casUrl!);
      prefs.setString('pronoteUrl', pronoteUrl!);
      prefs.setInt('interval', interval);
      prefs.setBool('fake', fake);
      prefs.setBool('check', check);

      int checkNoteAlarmId = 0;

      if (!Platform.isLinux) {
        await AndroidAlarmManager.cancel(checkNoteAlarmId);
      }

      if (!check) {
        print('Pas de vérification');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('C\'est enregistré, pas de vérification')),
        );

        return;
      }

      setState(() {
        loadingInProgress = true;
      });

      try {
        await checkNewMark(notify: false, forceAuth: true);
        await checkNewCanceledClasses(notify: false, forceAuth: false);

        if (!Platform.isLinux && !await AndroidAlarmManager.periodic(
          Duration(minutes: interval),
          checkNoteAlarmId,
          runAlarm,
          rescheduleOnReboot: true,
          allowWhileIdle: true,
        )) {
          showOkDialog(context, "Erreur",
              'Connexion réussie mais impossible de lancer la vérification en arrière-plan');
        } else {
          print('Connexion OK');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie et vérification activée')),
          );

          checkBatteryOptimisationDisabled();
        }
      } catch(e) {
        showOkDialog(context, "Erreur", e.toString());
      }

      setState(() {
        loadingInProgress = false;
      });
    }
  }
  
  void checkBatteryOptimisationDisabled() {
    DisableBatteryOptimization.showDisableAllOptimizationsSettings(
        'Activer le démarrage automatique de l\'application',
        'Suivez les instructions pour activer le démarrage automatique de l\'application',
        'Votre téléphone a des optimisations de batterie en plus',
        'Suivz les instructions pour désactiver les optimisations de la batterie pour que la vérification se fasse bien quand il faut');
  }
}