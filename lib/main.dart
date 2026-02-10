import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/responsive/size_config.dart';
import 'viewmodels/login_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/landing_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'views/landing/landing_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => LandingViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();

    return MaterialApp(
      title: 'GyBoree SmartKid',
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
      home: const LandingView(),
    );
  }
}
