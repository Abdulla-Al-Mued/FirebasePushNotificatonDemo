import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class FirebaseService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize Firebase
    // await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    await _requestNotificationPermission(messaging);

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification taps when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

    // Optionally get FCM token
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? fcmToken = prefs.getString('fcm_token');

    // if (fcmToken == null || fcmToken.isEmpty) {
    //   // Only get FCM token if it's not already stored
    //   await _getFcmToken(messaging);
    //
    //   print('its call now');
    // }
    await _getFcmToken(messaging);

    //await getApnsToken(messaging);
  }

  // Request notification permission on iOS
  static Future<void> _requestNotificationPermission(
      FirebaseMessaging messaging) async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: true,
        provisional: true
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("ic_logo");


    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentSound: true,  // ✅ Ensure sound is allowed when notifications arrive
      defaultPresentAlert: true,

    );

    InitializationSettings initializationSettings =
    const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: iosSettings

    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    //await Firebase.initializeApp();
    print('Handling background message: ${message.messageId}');

    // Extract notification and data
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    Map<String, dynamic>? data = message.data;


    _showNotification(title, body);


    if (data != null) {
      print('Notification Data: ${data['NotificationId']}');
      print('Notification Type Code: ${data['NotificationTypeCode']}');
    }
  }

  // Handle foreground messages
  static void _onForegroundMessage(RemoteMessage message) {
    print('Received a message in foreground: ${message.data}');

    // Extract notification and data
    String? title = message.notification?.title;
    String? body = message.notification?.body;
    Map<String, dynamic>? data = message.data;

    // Fallback to extract custom data from both notification and data sections
    String? notificationTypeCode = data?["NotificationTypeCode"] ??
        message.notification?.body; // Check data or notification body
    String? notificationId =
        data?['NotificationId'] ?? message.notification?.title;

    // Log the custom data
    print('Notification Id: $notificationId');
    print('Notification Type Code: $notificationTypeCode');

    // Show the notification in the foreground
    _showNotification(title, body);

    // Navigate based on notificationTypeCode
    if (notificationTypeCode != null) {
      _showNotification(title, body);
    }
  }

  // Handle when the user taps on a notification while the app is in the background
  static void _onNotificationOpened(RemoteMessage message) {
    print('Notification opened from background: ${message.data}');

    // Extract custom data fields
    Map<String, dynamic>? data = message.data;

    String? notificationTypeCode = data?['NotificationTypeCode'];
    String? notificationId = data?['NotificationId'];

    print('Notification Id: $notificationId');
    print('Notification Type Code: $notificationTypeCode');

    if (notificationTypeCode != null) {
      //_navigateBasedOnTypeCode(notificationTypeCode);
    }
  }

  // Get FCM token for push notifications and send it to the backend
  static Future<void> _getFcmToken(FirebaseMessaging messaging) async {
    String? token = await messaging.getToken();
    if (token != null) {
      print("FCM Token: $token");

    }
  }

  static Future<void> getApnsToken(FirebaseMessaging messaging)  async {


    String? apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) {
      print("FCM Token: $apnsToken");
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('fcm_token', apnsToken);
    }
    print('APNS Token: $apnsToken');
  }

  // Show notification in the notification bar

  static Future<void> _showNotification(String? title, String? body) async {
    // Use BigTextStyleInformation to display all text in the body
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body ?? 'No body',
      htmlFormatBigText: true,
      contentTitle: title ?? 'Notification',
      htmlFormatContentTitle: true, // Optional: allows HTML in the title
    );

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      styleInformation: bigTextStyleInformation, // Apply BigTextStyle
    );

    DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails, // Add iOS-specific details here
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'No title', // Title
      body ?? 'No body', // Body text
      notificationDetails,
    );
  }

  // Navigate to the Dashboard or other pages based on notificationTypeCode
  // static void _navigateBasedOnTypeCode(String? notificationTypeCode) {
  //   switch (notificationTypeCode) {
  //     case '01':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '02':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '03':
  //       Get.to(() => const StudentPaymentGrid());
  //       break;
  //     case '04':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '05':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '06':
  //       Get.to(() => const ActivePupilScreen());
  //       break;
  //     case '07':
  //       Get.to(() =>  LessonsGap());
  //       break;
  //     case '08':
  //       Get.to(() => const UnavailabilityGrid());
  //       break;
  //     case '09':
  //       Get.to(() => const BottomNavBar(initialIndex: 1,));
  //       break;
  //     case '10':
  //       Get.to(() => const ActivePupilScreen());
  //       break;
  //     case '11':
  //       Get.to(() => const ActivePupilScreen());
  //       break;
  //     case '12':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '13':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '14':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '15':
  //       Get.to(() => const UpCommingLesson());
  //       break;
  //     case '16':
  //       Get.to(() => const StudentPaymentGrid());
  //       break;
  //     case '17':
  //       Get.to(() => const ActivePupilScreen());
  //       break;
  //     default:
  //       Get.to(() => const EnterPin());
  //       break;
  //   }
  // }
}