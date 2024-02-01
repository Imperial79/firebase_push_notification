import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMconstants {
  static const String serverKey =
      "AAAAE_6Xrvk:APA91bGvesCoEApV40oXbZLfnDxaY5PpA-vUMH5PTYmty2NAFMCPG9bwW8ou-LfPm5X6uWd5qSeE5Z40eS08e2YDCjlRqxi8YTmis3lfa0kf4_eKYC27-vewQ2BSNhZe4-vTPAxEngAF";

  static const String fcmBaseUrl =
      "https://fcm.googleapis.com/v1/projects/push-notification-demo-7d645/messages:send";

  static String myToken = "";
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    "High Importance Notifications",
    description: "This channel is used for important messages",
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // Request Permission for sending notification
    await _firebaseMessaging.requestPermission();

    // Generate token to send notification
    String? FCMTOKEN = await FirebaseMessaging.instance.getToken();
    log("FCMTOKEN-> $FCMTOKEN");
    FCMconstants.myToken = FCMTOKEN!;

    // This will listen for the token and called whenever the token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FCMTOKEN = fcmToken;
      FCMconstants.myToken = FCMTOKEN!;
      log("Refreshed FCM Token-> $fcmToken");
    }).onError((err) {
      log(err);
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    initLocalNotification();

    FirebaseMessaging.onMessage.listen((message) {
      // Check manifest for some lines in the meta-data tag
      final notification = message.notification!;
      log("Title-> ${notification.title}");
      log("Body-> ${notification.body}");
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        "${notification.title!} This is Local Notification",
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future initLocalNotification() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,

      // onDidReceiveNotificationResponse: (details) {
      //   final message = RemoteMessage.fromMap(jsonDecode(details))
      // },
    );
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('title: ${message.notification!.title}');
  log('body: ${message.notification!.body}');
  log('data: ${message.data}');
}
