// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Constants {
  static const String serverKey =
      "AAAAE_6Xrvk:APA91bGvesCoEApV40oXbZLfnDxaY5PpA-vUMH5PTYmty2NAFMCPG9bwW8ou-LfPm5X6uWd5qSeE5Z40eS08e2YDCjlRqxi8YTmis3lfa0kf4_eKYC27-vewQ2BSNhZe4-vTPAxEngAF";

  static const String fcmBaseUrl =
      "https://fcm.googleapis.com/v1/projects/push-notification-demo-7d645/messages:send";

  static String myToken = "";
}

class FirebaseNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static void init() async {
    await _firebaseMessaging.requestPermission();

    String? FCMTOKEN = await FirebaseMessaging.instance.getToken();
    log("FCMTOKEN-> $FCMTOKEN");
    Constants.myToken = FCMTOKEN!;

    // This will listen for the token and called whenever the token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FCMTOKEN = fcmToken;
      Constants.myToken = FCMTOKEN!;
      log("Refreshed FCM Token-> $fcmToken");
    }).onError((err) {
      log(err);
    });

    FirebaseMessaging.onBackgroundMessage(
      (message) async {
        log("BACKGROUND MESSAGE RECIEVED");
        log('title: ${message.notification!.title}');
        log('body: ${message.notification!.body}');
        log('data: ${message.data}');
      },
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

class LocalNotification {
  static final _localNotification = FlutterLocalNotificationsPlugin();

  static final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    "High Importance Notifications",
    description: "This channel is used for important messages",
    importance: Importance.defaultImportance,
  );

  static void init() {
    final androidInit = AndroidInitializationSettings('@drawable/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {
        return;
      },
    );
    final LinuxInitializationSettings linuxInit =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      linux: linuxInit,
    );
    _localNotification.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        log("onDidReceiveNotificationResponse");
        log("Payload-> ${details.payload}");
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      log("Title-> ${message.notification!.title}");
      log("body-> ${message.notification!.body}");
      log("data-> ${message.data}");

      // Check manifest for some lines in the meta-data tag
      final notification = message.notification!;
      log("Title-> ${notification.title}");
      log("Body-> ${notification.body}");

      // if (notification == null) return;
      _localNotification.show(
        notification.hashCode,
        notification.title!,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
            actions: [
              AndroidNotificationAction('1', 'Open'),
            ],
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }
}
