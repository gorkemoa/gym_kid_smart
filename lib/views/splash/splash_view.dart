import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/color_utils.dart';
import '../../viewmodels/splash_view_model.dart';
import '../landing/landing_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewModel>().init();
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingView()),
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
