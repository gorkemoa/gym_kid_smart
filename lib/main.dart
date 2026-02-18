import 'dart:async';
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
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/landing_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/splash_view_model.dart';
import 'services/environment_service.dart';
import 'views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await EnvironmentService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => DailyReportViewModel()),
        ChangeNotifierProvider(create: (_) => ChatDetailViewModel()),
        ChangeNotifierProvider(create: (_) => PermissionViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
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
