
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:pronote_notification/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double interval = 15;
  bool check = true;

  bool isConnected = false;
  String? userFullName;
  String? schoolName;
  String? lastMarks;

  Future<bool> getSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    username = prefs.getString('username');
    password = prefs.getString('password');
    casUrl = prefs.getString('casUrl') ?? casUrls.first.value;
    pronoteUrl = prefs.getString('pronoteUrl') ?? pronoteUrls.first.value;
    interval = prefs.getDouble('interval') ?? interval;

    if (firstLoadSharedPreferencies) {
      check = prefs.getBool('check') ?? true;
    }

    firstLoadSharedPreferencies = false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        child: FutureBuilder<bool>(
            future: getSharedPreferences(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return
                  Padding(
                      padding: EdgeInsets.all(10),
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
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Intervalle de vérification\n' + interval.round().toString() + ' minutes'),
                                              Expanded(
                                                  child: Slider(
                                                    value: interval,
                                                    min: 15,
                                                    max: 4 * 60,
                                                    divisions: 15,
                                                    label: interval.round().toString() + ' minutes',
                                                    onChanged: (double value) {
                                                      setState(() {
                                                        interval = value;
                                                      });
                                                    },
                                                  )
                                              )
                                            ]
                                        )
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                        kDebugMode ? loadingInProgress ? const Text('Connexion en cours ...') : Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                _authPronote(true);
                                              },
                                              child: const Text('Tester'),
                                            )
                                        ) : Container(),
                                        kDebugMode ? Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                final prefs = await SharedPreferences.getInstance();
                                                await prefs.clear();
                                              },
                                              child: const Text('Reset'),
                                            )
                                        ) : Container(),
                                      ],
                                    )
                                  ],
                                )
                            ),
                            isConnected ? Text('Utilisateur : ' + (userFullName ?? '-'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),) : Container(),
                            isConnected ? Text('Établissement : ' + (schoolName ?? '-'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),) : Container(),
                            isConnected ? Text('Dernière note : ' + (lastMarks ?? '-'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),) : Container(),
                          ]
                      )
                  );
              }

              return const Center(child: CircularProgressIndicator());
            }
        )
    );
  }

  Future<void> _authPronote(bool fake) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isConnected = false;

        userFullName = null;
        schoolName = null;
        lastMarks = null;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username!);
      prefs.setString('password', password!);
      prefs.setString('casUrl', casUrl!);
      prefs.setString('pronoteUrl', pronoteUrl!);
      prefs.setBool('fake', fake);
      prefs.setBool('check', check);
      prefs.remove('lastMarksId');

      if (!check) {
        print('Pas de vérification');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('C\'est enregistré !')),
        );

        return;
      }

      setState(() {
        loadingInProgress = true;
      });

      SessionPronote sessionPronote = SessionPronote(
          casUrl!, pronoteUrl!, useFake: fake);
      try {
        await sessionPronote.auth(username!, password!);

        userFullName = sessionPronote.getUserFullName();
        schoolName = sessionPronote.getSchoolName();

        Exam? lastMark = sessionPronote.getLastMark();

        if (lastMark != null && lastMark.mark?.valeur != null) {
          lastMarks = lastMark.toString();
        }

        setState(() {
          isConnected = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie !')),
        );
      } catch (e) {
        showOkDialog(context, "Erreur", e.toString());
      }

      setState(() {
        loadingInProgress = false;
      });
    }
  }
}