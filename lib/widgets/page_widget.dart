import 'package:flutter/material.dart';
import 'package:pronote_notification/widgets/account_info_widget.dart';
import 'package:pronote_notification/widgets/app_info_widget.dart';
import 'package:pronote_notification/widgets/help_widget.dart';
import 'package:pronote_notification/widgets/last_marks_widget.dart';
import 'package:pronote_notification/widgets/settings_widget.dart';

class PageWidget extends StatefulWidget {
  const PageWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageWidgetState();
  }
}

class _PageWidgetState extends State<PageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pronote notification'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                children: [
                  const HelpWidget(),
                  const SettingsWidget(),
                  Wrap(
                      alignment: WrapAlignment.center,
                      children: const [
                        LastMarksWidget(),
                        AccountInfoWidget(),
                      ]
                  ),
                  const AppInfoWidget(),
                ]
            ),
          ),
        )
    );
  }
}