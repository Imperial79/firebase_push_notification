import 'dart:convert';
import 'dart:developer';
import 'package:firebase_push_notification/Api/notification_config.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  Future<String> _generateAccessToken() async {
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

    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }

  _sendNotification() async {
    final body = {
      "message": {
        "token": Constants.myToken,
        "notification": {
          "title": "Notification Title",
          "body": "Notification Body"
        },
        "data": {"key": "value"}
      }
    };
    String accessToken = await _generateAccessToken();
    var res = await http.post(
      Uri.parse(Constants.fcmBaseUrl),
      headers: {
        "Content-Type": 'application/json',
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(body),
    );
    log("Response-> ${res.body}");
    log("Status Code-> ${res.statusCode}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _sendNotification,
          child: const Text("Send Notifications"),
        ),
      ),
    );
  }
}
