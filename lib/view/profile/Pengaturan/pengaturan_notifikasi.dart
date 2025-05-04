import 'package:flutter/material.dart';

import '../../component/custom_appbar.dart';
import '../../component/custom_switch.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Switch state variables
  bool generalNotifications = true;
  bool soundNotifications = true;
  bool vibrationNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Notifikasi',
        onBackPressed: () => Navigator.pushNamed(context, "/home"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            SwitchSettingRow(
              title: 'Notifikasi Umum',
              value: generalNotifications,
              onChanged: (value) {
                setState(() {
                  generalNotifications = value;
                });
              },
            ),
            CustomDivider(),
            SwitchSettingRow(
              title: 'Suara',
              value: soundNotifications,
              onChanged: (value) {
                setState(() {
                  soundNotifications = value;
                });
              },
            ),
            CustomDivider(),
            SwitchSettingRow(
              title: 'Getar',
              value: vibrationNotifications,
              onChanged: (value) {
                setState(() {
                  vibrationNotifications = value;
                });
              },
            ),
            CustomDivider(),
          ],
        ),
      ),
    );
  }
}



class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
    );
  }
}
