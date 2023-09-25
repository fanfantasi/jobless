import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:jobless/core/config.dart';
import 'package:jobless/data/service/firebaseapi.dart';

class LocalNotification {
  Future<String> base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }

  Future<Uint8List> getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<void> showNotification(
      {id, displayname, message, avatar, payload}) async {
    final Person receiver = Person(
        name: displayname,
        key: id,
        icon: ByteArrayAndroidIcon.fromBase64String(
            await base64encodedImage(avatar)));

    //No Picture
    final List<Message> messages = <Message>[
      Message(message, DateTime.now(), receiver),
    ];

    // ignore: unused_local_variable
    final MessagingStyleInformation messagingStyle = MessagingStyleInformation(
        receiver,
        groupConversation: false,
        htmlFormatContent: true,
        htmlFormatTitle: true,
        messages: messages);

    //Send Notification
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Config.appName,
      Config.appName,
      channelDescription: Config.appName,
      styleInformation: messagingStyle,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, displayname, message, platformChannelSpecifics,
        payload: payload);
  }
}
