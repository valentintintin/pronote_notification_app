import 'package:flutter/material.dart';

class HelpWidget extends StatelessWidget {
  const HelpWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: const [
          Text('Application qui vous notifie lorsqu\'il y a une nouvelle note sur Pronote', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text('Vos identifiants ne sont envoyés à personne, tout est fait sur votre téléphone :)'),
          )
        ]
    );
  }

}