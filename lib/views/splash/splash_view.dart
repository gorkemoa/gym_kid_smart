import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/color_utils.dart';
import '../../core/services/navigation_service.dart';
import '../../models/environment_model.dart';
import '../../services/environment_service.dart';
import '../../viewmodels/splash_view_model.dart';
import '../anaokulu/landing/landing_view.dart';
import '../oyungrubu/home/oyungrubu_home_view.dart';
import '../environment_selection/environment_selection_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SplashViewModel>().init();
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final config = EnvironmentService.currentConfig;

      if (config != null) {
        if (config.environment == AppEnvironment.oyunGrubu) {
          final prefs = await SharedPreferences.getInstance();
          final userKey = prefs.getString('oyungrubu_user_key');
          if (userKey != null && userKey.isNotEmpty) {
            NavigationService.pushNamedAndRemoveUntil(
              const OyunGrubuHomeView(),
            );
            return;
          }
        } else if (config.environment == AppEnvironment.anaokulu) {
          final prefs = await SharedPreferences.getInstance();
          final userData = prefs.getString('user_data');
          if (userData != null && userData.isNotEmpty) {
            NavigationService.pushNamedAndRemoveUntil(const LandingView());
            return;
          }
        }
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EnvironmentSelectionView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: ColorUtils.fromHex('#1f2549'),
          body: Center(
            child: Image.asset(
              'assets/app-logo.jpg',
              width:
                  SizeTokens.w100 * 3, // Increased size for better visibility
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
