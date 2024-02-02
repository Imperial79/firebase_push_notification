import 'package:firebase_push_notification/Api/notification_config.dart';

import 'package:flutter/material.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                await SendNotification.toUser(Constants.myToken);
              },
              child: const Text("Send to Me"),
            ),
            ElevatedButton(
              onPressed: () async {
                await SendNotification.toTopic('All');
              },
              child: const Text("Send to Topic 'All'"),
            ),
          ],
        ),
      ),
    );
  }
}
