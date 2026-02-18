import 'package:flutter/material.dart';
import '../profile/oyungrubu_profile_view.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../../../core/utils/app_translations.dart';

class OyunGrubuHomeView extends StatelessWidget {
  const OyunGrubuHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SplashViewModel>(
          builder: (context, splashVM, _) => Text(
            AppTranslations.translate('oyun_grubu', splashVM.locale.languageCode),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OyunGrubuProfileView()),
              );
            },
          ),
        ],
      ),
      body: Consumer<SplashViewModel>(
        builder: (context, splashVM, _) => Center(
          child: Text(
            AppTranslations.translate(
              'oyun_grubu_coming_soon',
              splashVM.locale.languageCode,
            ),
          ),
        ),
      ),
    );
  }
}
