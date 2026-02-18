import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/oyungrubu_login_view_model.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/splash_view_model.dart';
import 'widgets/oyungrubu_login_form.dart';

class OyunGrubuLoginView extends StatefulWidget {
  const OyunGrubuLoginView({super.key});

  @override
  State<OyunGrubuLoginView> createState() => _OyunGrubuLoginViewState();
}

class _OyunGrubuLoginViewState extends State<OyunGrubuLoginView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuLoginViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuLoginViewModel, SplashViewModel>(
      builder: (context, loginVM, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: SizeTokens.p32 * 2),
                  Image.asset(
                    'assets/app-logo.jpg',
                    height: SizeTokens.h120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.child_care,
                      size: SizeTokens.i64,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p32),
                  Text(
                    AppTranslations.translate('oyungrubu_login_title', locale),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeTokens.f24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: SizeTokens.p12),
                  Text(
                    AppTranslations.translate(
                      'oyungrubu_login_subtitle',
                      locale,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: SizeTokens.p32),
                  const OyunGrubuLoginForm(),
                  SizedBox(height: SizeTokens.p24),
                  _BackToSelection(locale: locale),
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

class _BackToSelection extends StatelessWidget {
  final String locale;

  const _BackToSelection({required this.locale});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: Colors.white.withOpacity(0.8),
        size: SizeTokens.i16,
      ),
      label: Text(
        AppTranslations.translate('change_section', locale),
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: SizeTokens.f14,
        ),
      ),
    );
  }
}

class _PoweredBy extends StatelessWidget {
  const _PoweredBy();

  @override
  Widget build(BuildContext context) {
    final locale = context.read<SplashViewModel>().locale.languageCode;
    return Column(
      children: [
        Text(
          AppTranslations.translate('powered_by', locale),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: SizeTokens.f12,
          ),
        ),
        SizedBox(height: SizeTokens.p4),
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
