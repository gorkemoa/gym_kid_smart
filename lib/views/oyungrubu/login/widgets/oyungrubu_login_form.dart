import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../viewmodels/oyungrubu_login_view_model.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../viewmodels/splash_view_model.dart';
import '../../home/oyungrubu_home_view.dart';

class OyunGrubuLoginForm extends StatelessWidget {
  const OyunGrubuLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuLoginViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Column(
          children: [
            TextField(
              controller: viewModel.emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: SizeTokens.f14),
              decoration: InputDecoration(
                hintText: AppTranslations.translate('email', locale),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.passwordController,
              obscureText: true,
              style: TextStyle(fontSize: SizeTokens.f14),
              decoration: InputDecoration(
                hintText: AppTranslations.translate('password', locale),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            if (viewModel.errorMessage != null) ...[
              SizedBox(height: SizeTokens.p16),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p12,
                  vertical: SizeTokens.p8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.r8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: SizeTokens.i16,
                    ),
                    SizedBox(width: SizeTokens.p8),
                    Expanded(
                      child: Text(
                        AppTranslations.translate(
                          viewModel.errorMessage!,
                          locale,
                        ),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: SizeTokens.f12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: SizeTokens.p24),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.login();
                      if (success && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OyunGrubuHomeView(),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(double.infinity, SizeTokens.h52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                ),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: SizeTokens.h20,
                      width: SizeTokens.h20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      AppTranslations.translate('login_button', locale),
                      style: TextStyle(fontSize: SizeTokens.f16),
                    ),
            ),
          ],
        );
      },
    );
  }
}
