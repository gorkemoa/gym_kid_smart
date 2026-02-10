import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/login_view_model.dart';
import '../../core/utils/app_translations.dart';
import '../../core/utils/color_utils.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../viewmodels/settings_view_model.dart';
import 'widgets/login_form.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsViewModel, LandingViewModel, LoginViewModel>(
      builder: (context, settingsVM, landingVM, loginVM, child) {
        final settings = settingsVM.settings;
        final backgroundColor = ColorUtils.fromHex(
          settings?.otherColor ?? '#1a237e',
        );
        final locale = landingVM.locale.languageCode;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: SizeTokens.p32 * 2),
                  // App Logo/Illustration
                  if (settings?.logo != null)
                    Image.network(
                      settings!.logoUrl,
                      height: SizeTokens.h120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                            'assets/landing.svg',
                            height: SizeTokens.h120,
                            fit: BoxFit.contain,
                          ),
                    )
                  else
                    SvgPicture.asset(
                      'assets/landing.svg',
                      height: SizeTokens.h120,
                      fit: BoxFit.contain,
                    ),
                  SizedBox(height: SizeTokens.p32),
                  Text(
                    AppTranslations.translate('landing_title', locale),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: SizeTokens.f24,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p12),
                  Text(
                    AppTranslations.translate('landing_subtitle', locale),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: SizeTokens.f14,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p32),
                  const LoginForm(),
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
    final locale = context.read<LandingViewModel>().locale.languageCode;
    return Column(
      children: [
        Text(
          AppTranslations.translate('powered_by', locale),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
        SizedBox(height: SizeTokens.p4),
        // Use the logo from assets if available, otherwise text
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
