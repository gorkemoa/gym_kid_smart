import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/app_translations.dart';
import '../../core/utils/color_utils.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../viewmodels/settings_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../core/services/navigation_service.dart';
import '../home/home_view.dart';
import '../login/login_view.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final landingVM = context.read<LandingViewModel>();
      final loginVM = context.read<LoginViewModel>();
      final settingsVM = context.read<SettingsViewModel>();

      await landingVM.init();
      if (context.mounted) {
        await loginVM.init();
      }
      if (context.mounted) {
        settingsVM.fetchSettings();
      }

      if (context.mounted && loginVM.data?.data != null) {
        NavigationService.pushNamedAndRemoveUntil(const HomeView());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsViewModel, LandingViewModel>(
      builder: (context, settingsVM, landingVM, child) {
        if (settingsVM.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = settingsVM.settings;
        final backgroundColor = ColorUtils.fromHex(
          settings?.otherColor ?? '#1a237e',
        );
        final primaryColor = ColorUtils.fromHex(
          settings?.mainColor ?? '#f9991c',
        );
        final locale = landingVM.locale.languageCode;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              child: Column(
                children: [
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/landing.svg',
                    height: SizeTokens.h300,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  Text(
                    AppTranslations.translate('landing_title', locale),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: SizeTokens.f28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p16),
                  Text(
                    AppTranslations.translate('landing_subtitle', locale),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryColor, // Use main_color for the button
                      minimumSize: Size(double.infinity, SizeTokens.h60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeTokens.r12),
                      ),
                    ),
                    child: Text(
                      AppTranslations.translate('start_now', locale),
                      style: TextStyle(
                        fontSize: SizeTokens.f20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeTokens.p24),
                  const _PoweredBy(),
                  SizedBox(height: SizeTokens.p24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PoweredBy extends StatelessWidget {
  const _PoweredBy();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    return Column(
      children: [
        Text(
          AppTranslations.translate('powered_by', locale),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: SizeTokens.f12,
          ),
        ),
        SizedBox(height: SizeTokens.p8),
        Image.asset(
          'assets/smartmetrics-logo.png',
          height: SizeTokens.h20,
          errorBuilder: (context, error, stackTrace) => Text(
            'SmartMetrics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: SizeTokens.f16,
            ),
          ),
        ),
      ],
    );
  }
}
