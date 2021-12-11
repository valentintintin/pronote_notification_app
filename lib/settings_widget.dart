import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pronote_notification/pronote/models/response/page_accueil.dart';
import 'package:pronote_notification/pronote/session_pronote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem<String>> pronoteUrls = {
    'Choix de l\'Établissement': '',
    'Lycée Léonard de Vinci - Villefontaine': 'https://0382440w.index-education.net/pronote/',
    'Collège Fernand Bouvier - Saint Jean de Bournay': 'https://0382265f.index-education.net/pronote/',
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

    if (firstLoadSharedPreferencies) {
      check = prefs.getBool('check') ?? true;
    }

    firstLoadSharedPreferencies = false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: getSharedPreferences(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Column(
                children: [
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
                  ),
                  isConnected ? Text('Utilisateur : ' + (userFullName ?? '-')) : Container(),
                  isConnected ? Text('Établissement : ' + (schoolName ?? '-')) : Container(),
                  isConnected ? Text('Dernière note : ' + (lastMarks ?? '-')) : Container(),
                ]
            );
          }

          return const Center(child: CircularProgressIndicator());
        }
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
        print('Pas de test');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ok, plus de vérification')),
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

        setState(() {
          isConnected = true;

          userFullName = sessionPronote.user.userFullName;
          schoolName = sessionPronote.user.etablissement?.etablissement?.name;

          Devoir? devoir = sessionPronote.homePage.notes?.listeDevoirs?.devoirs?.last;
          if (devoir != null && devoir.note?.valeur != null) {
            lastMarks = devoir.toString();
            prefs.setString('lastMarksId', lastMarks!);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie !')),
        );
      } catch (e) {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('AlertDialog Title'),
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
        loadingInProgress = false;
      });
    }
  }
}