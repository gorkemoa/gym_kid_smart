import 'package:flutter/material.dart';
import 'package:gym_kid_smart/views/anaokulu/landing/landing_view.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/app_translations.dart';
import '../../viewmodels/environment_selection_view_model.dart';
import '../../viewmodels/splash_view_model.dart';
import '../oyungrubu/login/oyungrubu_login_view.dart';
import '../oyungrubu/home/oyungrubu_home_view.dart';
import '../../models/environment_model.dart';
import '../../core/services/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvironmentSelectionView extends StatelessWidget {
  const EnvironmentSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnvironmentSelectionViewModel(),
      child: const _EnvironmentSelectionContent(),
    );
  }
}

class _EnvironmentSelectionContent extends StatelessWidget {
  const _EnvironmentSelectionContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EnvironmentSelectionViewModel>();
    final locale = context.watch<SplashViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Netflix-style dark background
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: SizeTokens.p40),
            Text(
              AppTranslations.translate('select_environment_title', locale),
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeTokens.f24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: viewModel.environments.map((config) {
                  return _EnvironmentCard(
                    onTap: () async {
                      await viewModel.selectEnvironment(config);
                      if (!context.mounted) return;

                      if (config.environment == AppEnvironment.oyunGrubu) {
                        final prefs = await SharedPreferences.getInstance();
                        final userKey = prefs.getString('oyungrubu_user_key');
                        if (userKey != null && userKey.isNotEmpty) {
                          NavigationService.pushNamedAndRemoveUntil(
                            const OyunGrubuHomeView(),
                          );
                          return;
                        }

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OyunGrubuLoginView(),
                          ),
                        );
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LandingView(),
                          ),
                        );
                      }
                    },
                    name: AppTranslations.translate(
                      config.translationKey,
                      locale,
                    ),
                    iconAsset: config.iconAsset,
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            Text(
              AppTranslations.translate('select_environment_subtitle', locale),
              style: TextStyle(color: Colors.white70, fontSize: SizeTokens.f14),
            ),
            SizedBox(height: SizeTokens.p40),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentCard extends StatefulWidget {
  final VoidCallback onTap;
  final String name;
  final String iconAsset;

  const _EnvironmentCard({
    required this.onTap,
    required this.name,
    required this.iconAsset,
  });

  @override
  State<_EnvironmentCard> createState() => _EnvironmentCardState();
}

class _EnvironmentCardState extends State<_EnvironmentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: SizeTokens.w100 * 1.2,
            height: SizeTokens.w100 * 1.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeTokens.r12),
              border: Border.all(
                color: _isHovered ? Colors.white : Colors.transparent,
                width: 3,
              ),
              image: DecorationImage(
                image: AssetImage(widget.iconAsset),
                fit: BoxFit.cover,
                colorFilter: _isHovered
                    ? null
                    : ColorFilter.mode(
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
              ),
            ),
          ),
          SizedBox(height: SizeTokens.p12),
          Text(
            widget.name,
            style: TextStyle(
              color: _isHovered ? Colors.white : Colors.white70,
              fontSize: SizeTokens.f16,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
