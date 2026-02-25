import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gym_kid_smart/viewmodels/chat_detail_view_model.dart';
import 'package:gym_kid_smart/viewmodels/daily_report_view_model.dart';
import 'package:gym_kid_smart/viewmodels/permission_view_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/services/navigation_service.dart';
import 'core/responsive/size_config.dart';
import 'viewmodels/login_view_model.dart';
import 'viewmodels/oyungrubu_login_view_model.dart';
import 'viewmodels/oyungrubu_profile_view_model.dart';
import 'viewmodels/oyungrubu_home_view_model.dart';
import 'viewmodels/oyungrubu_student_history_view_model.dart';
import 'viewmodels/oyungrubu_notifications_view_model.dart';
import 'viewmodels/oyungrubu_qr_scanner_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/oyungrubu_settings_view_model.dart';
import 'viewmodels/landing_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/splash_view_model.dart';
import 'services/environment_service.dart';
import 'services/auth_service.dart';
import 'services/push_notification_service.dart';
import 'services/oyungrubu_notification_service.dart';
import 'views/splash/splash_view.dart';
import 'views/anaokulu/notice/notice_view.dart';
import 'views/oyungrubu/notifications/oyungrubu_notifications_view.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> _handleFCMNavigation(RemoteMessage message) async {
  final data = message.data;
  final page = data['page'];
  if (page != null) {
    if (page == '/announcements') {
      final user = await AuthService().getSavedUser();
      if (user != null) {
        NavigationService.navigateTo(NoticeView(user: user));
      }
    } else if (page == '/qrNotifications') {
      NavigationService.navigateTo(const OyunGrubuNotificationsView());
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Enable foreground notifications on iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // FCM İzinleri İste (Özellikle iOS için zorunlu)
  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // Firebase topic'ine abone ol (backend buradan gönderiyor)
  try {
    await FirebaseMessaging.instance.subscribeToTopic(
      'php_notification_gymkid',
    );
    debugPrint('Subscribed to topic: php_notification_gymkid');
  } catch (e) {
    debugPrint('Failed to subscribe to topic: $e');
  }

  // FCM Token Al ve Yazdır
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('=============================================');
    debugPrint('FCM Token: $token');
    debugPrint('=============================================');

    // Token yenilendiğinde dinle (Opsiyonel ama iyi pratik)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token Refreshed: $newToken');
      // Anaokulu Token Güncelleme
      final authService = AuthService();
      final savedUser = await authService.getSavedUser();
      if (savedUser != null) {
        final pushService = PushNotificationService();
        await pushService.addToken(
          schoolId: savedUser.schoolId ?? 1,
          userKey: savedUser.userKey ?? '',
        );
      }

      // OyunGrubu Token Güncelleme
      final oyunGrubuPushService = OyunGrubuNotificationService();
      await oyunGrubuPushService.updateFCMToken();
    });

    // Bildirime tıklanma durumları (Background / Terminated -> Foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleFCMNavigation(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        // Gecikmeli yönlendirme, app'in init olmasını beklemek için
        Future.delayed(const Duration(seconds: 2), () {
          _handleFCMNavigation(message);
        });
      }
    });
  } catch (e) {
    debugPrint('FCM Token alınırken hata oluştu: $e');
  }

  await initializeDateFormatting();
  await EnvironmentService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()..init()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => DailyReportViewModel()),
        ChangeNotifierProvider(create: (_) => ChatDetailViewModel()),
        ChangeNotifierProvider(create: (_) => PermissionViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => OyunGrubuLoginViewModel()),
        ChangeNotifierProvider(create: (_) => OyunGrubuProfileViewModel()),
        ChangeNotifierProvider(create: (_) => OyunGrubuHomeViewModel()),
        ChangeNotifierProvider(
          create: (_) => OyunGrubuStudentHistoryViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => OyunGrubuNotificationsViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => OyunGrubuSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => OyunGrubuQRScannerViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Check initial connectivity with a small delay to allow OS to stabilize
    Future.delayed(const Duration(milliseconds: 1000), () {
      Connectivity().checkConnectivity().then(_handleConnectivityChange);
    });
    // Listen for changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // If results contains ANY connection type other than none, we have internet.
    final bool hasInternet = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasInternet) {
      _showNoInternetDialog();
    } else {
      _hideNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing) return;

    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('İnternet Bağlantısı Yok'),
        content: const Text(
          'Uygulamayı kullanabilmek için lütfen internet bağlantınızı kontrol edin.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogShowing = false;
              Navigator.pop(dialogContext);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  void _hideNoInternetDialog() {
    if (!_isDialogShowing) return;

    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    // We can use the navigatorKey to pop the dialog if we are sure it's showing
    // Note: This assumes the top-most route is our dialog.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      _isDialogShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: 'GymBoree SmartKid',
        debugShowCheckedModeBanner: false,
        theme: settingsViewModel.themeData,
        builder: (context, child) {
          // Initialize SizeConfig
          SizeConfig().init(context);

          return MediaQuery(
            // Font Scaling Protection: Sistem ayarlarından yazı tipi boyutu değiştirilse bile
            // tasarımın bozulmaması için TextScaler.noScaling eklenmelidir.
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
        home: const SplashView(),
      ),
    );
  }
}
