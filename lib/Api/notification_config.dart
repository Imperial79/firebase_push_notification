// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class Constants {
  static const String serverKey =
      "AAAAE_6Xrvk:APA91bGvesCoEApV40oXbZLfnDxaY5PpA-vUMH5PTYmty2NAFMCPG9bwW8ou-LfPm5X6uWd5qSeE5Z40eS08e2YDCjlRqxi8YTmis3lfa0kf4_eKYC27-vewQ2BSNhZe4-vTPAxEngAF";

  static const String fcmBaseUrl =
      "https://fcm.googleapis.com/v1/projects/push-notification-demo-7d645/messages:send";

  static String myToken = "";
}

class FirebaseNotification {
  final fcmMessaging = FirebaseMessaging.instance;

  static void init() async {
    await FirebaseNotification().fcmMessaging.requestPermission();

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

    await FirebaseNotification()
        .fcmMessaging
        .subscribeToTopic('All')
        .then((value) {
      log("Subscribed to 'All' topic");
    });
  }

  static Future<String> generateAccessToken() async {
    // How to generate Oauth 2.0 credentials
    // 1. Go to cloud console -> In the project name
    // 2. Go to Service Account -> Generate a Private Key -> Download the JSON file generated
    // 3. Copy All the credentials from the JSON File and paste in the method below.
    // 4. Install the googleapis_auth package from pub.dev and generate the accessToken everytime sending a new request for notification.

    final credentials = auth.ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "push-notification-demo-7d645",
      "private_key_id": "36d99217205c261deee0c97975da7996e73d3505",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDroHB+Etqy0Pvt\n+lBYRs1iOqZJEAZa+nelzK7Ae4Ca61fmPHw4lEtKYRLtymWNDnHPhTYMbRSEq36f\n5DBM8xzAeN+79endLDGpD0sk/N32pkSE7riUm2CQvaiqCqmZ9c1bB3X5Ek2pUeig\n/HnlW7jQsYTPBS2+yWmZwBquN02QFAYVxpD5IEETB4z/RsTcYySLGuCRawnK6zM9\nZoRbr6SL01V9NP13cIx88syLohzRPOzjZxA15ZINGPau8eWj5TNwaQVWqNIh+d36\nOqW2AGe8iC1C6qqqfC8qSi0yuPFtWI5jCc4nnFcKZYx9EcCZnSi7nEprHi7UBdN/\n+pJ9puGrAgMBAAECggEAHuBrXVoDJqOUH99JYAgHKfQdjj13V7yyqRtlWvvUInjs\nj9MlRBTKuPh3jomTPSTDbTo7lu1EXw5KDZHNcof5II+2Yd8bwkvkRg8m/bXVMFkh\naXoO3gpuYQk5bO7wwqgfPOqBXx4y5xlArrfnEVMvqMlaafZ3xCSIngk6ddHxbAuz\nS/DgKCeutcj/EJVBWz6S07ujzlolRU4zysulVoGk+NUrEDTDJ1uZr+MVxsQG5OhC\n05kFr8D6ODoXNq/+hv7hu98CgyxT5Of1ycWhxuPIVFOeTlYoA6JUHT8TLESh7giA\no4Qr8c7Fr6BwL+BB5AxHbnOhLgXrE5M43VjUEa/n4QKBgQD8Y2i2vbnHfYTuyzrl\nYJjMAJaWhxltOwkvCGvldg8Wa2UwZkpq09vViSK6YLnIkMMgztCCvsyj3VhoR7WD\n2tat5/pt9c+kSu/V5OcNUhrHyxLB7UVr79wtE4ed28Mu4slVMegiFPa4NONHX3FV\n8RMiydpwGZavpJrpKLaAygjuXQKBgQDu/6BiIWle1NVXsArcfN2ZscqIde5MkioA\nmaGMHN0kh2LwlatlkGvJF3D9fA24Q1zUq20jrfxfyF182jP/zao45rnCHnfpAQPA\nQGNZD25pcvNfl1SwyN0Qh3ZbA70tLZodDTegr7gd/Msg+lHJj6xg9ZnM6i2t4Ztu\ncAQ8UCy/pwKBgG9E8FxoZqhBeULBzHRl0tdVhw5T/2y9sz3OC6t9EgfDTzg4UKSq\nRGfu7qWWkTGQSMaFBz4tGhFAO4K14pt/9ldzR2AFGAcJlpUJNqgTw4TDzcA7d/iv\nJbWlv4tj4Lgh+bsapomoDmGFx5GmzVOjVdlnfmsfjORgwH78mQFMkQVtAoGAdhq4\npQWhzo0aiGSkWWUTFRp43Yp5ojkwrG8/F8BDwANvbzhnJJ+DxDHjUkB1fzM6spWs\nL0+RQbwABuzFeYmmrsvFzBnGY8xukBjBf4dSpqV5gymDXoFETSDD6iIk4CiC2gxo\nCu4K7Da6IqfQtuxa4Oc9g7fNrvmoF6EfVrbABk0CgYBwfm8zSfMjWVwRrLqqW/Gt\n9ljfSMl1PnP5435jzUe+Zim0xc+mzj5dkaQSlb+TdrdDsjf+LzxSL1x9HJeXat5g\nMFHyY0mKHATT+rvsJZkonRRKQIgqjOfVL0v4rpf7jS7LPeuSNI3w1ONeIeXCdwsK\njJAvsQdCPkRCVUyTRLH9OA==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-4wmti@push-notification-demo-7d645.iam.gserviceaccount.com",
      "client_id": "105087091625434077287",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-4wmti%40push-notification-demo-7d645.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    final client = await auth.clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    return client.credentials.accessToken.data;
  }
}

class LocalNotification {
  static final _localNotification = FlutterLocalNotificationsPlugin();

  static final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    "High Importance Notifications",
    description: "This channel is used for important messages",
    importance: Importance.high,
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

    FirebaseMessaging.onMessage.listen((message) async {
      log("New Message!!!");
      log("Title-> ${message.notification!.title}");
      log("body-> ${message.notification!.body}");
      log("body-> ${message.notification!.android!.imageUrl}");
      log("data-> ${message.data}");

      // Check manifest for some lines in the meta-data tag
      final notification = message.notification!;
      log("Title-> ${notification.title}");
      log("Body-> ${notification.body}");

      // if (notification == null) return;

      final _bigPicture = await urlToAndroidBitmap(
          notification.android!.imageUrl!, 'bigPicture');
      final _largePicture = await urlToAndroidBitmap(
          message.data["largePicture"], 'largePicture');
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
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(_bigPicture),
              largeIcon: FilePathAndroidBitmap(_largePicture),
            ),
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }
}

Future<String> urlToAndroidBitmap(String url, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final response = await http.get(Uri.parse(url));
  final file = File(filePath);

  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

class SendNotification {
  static Future<void> toUser(String userToken) async {
    final body = {
      "message": {
        "token": userToken,
        "notification": {
          "title": "Notification to me",
          "body": "Body to me",
          "image": "https://source.unsplash.com/random",
        },
        "data": {"largePicture": "https://source.unsplash.com/random"},
      }
    };

    String accessToken = await FirebaseNotification.generateAccessToken();
    try {
      final res = await http.post(
        Uri.parse(Constants.fcmBaseUrl),
        headers: {
          "Content-Type": 'application/json',
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      );
      log(res.body.toString());
    } catch (e) {
      log("Some error occurred-> $e");
    }
  }

  static Future<void> toTopic(String topic) async {
    final body = {
      "message": {
        "notification": {
          "title": "Notification Title",
          "body": "Notification Body",
          "image": "https://source.unsplash.com/random",
        },
        "data": {"largePicture": "https://source.unsplash.com/random"},
        "topic": topic,
      }
    };

    String accessToken = await FirebaseNotification.generateAccessToken();
    try {
      await http.post(
        Uri.parse(Constants.fcmBaseUrl),
        headers: {
          "Content-Type": 'application/json',
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      log("Some error occurred-> $e");
    }
  }
}
