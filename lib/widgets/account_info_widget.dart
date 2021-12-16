import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pronote_notification/service.dart';

class AccountInfoWidget extends StatefulWidget {
  const AccountInfoWidget({Key? key}) : super(key: key);

  @override
  State<AccountInfoWidget> createState() => _AccountInfoWidgetState();
}

class _AccountInfoWidgetState extends State<AccountInfoWidget> {
  StreamSubscription? streamSubscription;

  String? userFullName;
  String? schoolName;
  
  @override
  void initState() {
    streamSubscription = streamPronoteSession.listen((session) {
      setState(() {
        userFullName = session?.getUserFullName();
        schoolName = session?.getSchoolName();
      });
    });
  }
  
  @override
  void dispose() {
    streamSubscription?.cancel();  
  }

  @override
  Widget build(BuildContext context) {
    return userFullName != null ? Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text('Information sur le compte', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    Text('Utilisateur : ' + (userFullName ?? 'inconnu'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                    Text('Établissement : ' + (schoolName ?? 'inconnu'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                  ],
                )
              ),
            ]
        ),
      ),
    ) : SizedBox();
  }
}