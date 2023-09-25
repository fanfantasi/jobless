import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jobless/core/local_notification.dart';
import 'package:jobless/core/navigationservice.dart';
import 'package:jobless/core/utils/constants.dart';
import '../../injection_container.dart' as di;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  LocalNotification().showNotification(
      id: message.data["id"],
      avatar: message.data["avatar"] ??
          'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png',
      displayname: message.data["title"] ?? 'Jobless',
      message: message.data['body'] ?? '',
      payload: message.data['payload'] ?? '');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
String? selectedNotificationPayload;

Future<void> onSelectNotification(String? payload) {
  var link = payload!.split('/');
  if (link.length > 1) {
    di.getIt<NavigationService>().navigateTo('/${link[0]}', arguments: link[1]);
  } else {
    di.getIt<NavigationService>().navigateTo('/${link[0]}');
  }
  return Future<void>.value();
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseApi _singleton = FirebaseApi._internal();

  factory FirebaseApi() {
    return _singleton;
  }

  FirebaseApi._internal() {
    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    debugPrint('message ${message.data}');
    LocalNotification().showNotification(
        id: 'notif',
        avatar: message.data["avatar"] ??
            'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png',
        displayname: message.data["title"] ?? 'Jobless',
        message: message.data['body'] ?? '',
        payload: message.data['payload'] ?? '');
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }

  Future initPushNotifications() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
    String initialRoute = Routes.welcomePage;
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.payload;
      initialRoute = Routes.navbarPage;
    } else {
      initialRoute;
    }

    AndroidInitializationSettings? initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (value) {
      // selectNotificationStream.add(value);
      onSelectNotification(value);
    });

    if (Platform.isIOS) {
      _handleIosNotificationPermissaion();
    } else {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      debugPrint('Token : $fcmToken');
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future _handleIosNotificationPermissaion() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }
}
