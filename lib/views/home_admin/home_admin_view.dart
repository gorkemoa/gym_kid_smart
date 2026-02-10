import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/app_translations.dart';
import '../login/login_view.dart';

class HomeAdminView extends StatelessWidget {
  const HomeAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginViewModel>().data?.data;
    final locale = context.read<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppTranslations.translate('admin_panel', locale)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: AppTranslations.translate('logout', locale),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.image != null
                  ? NetworkImage(user!.image!)
                  : null,
              child: user?.image == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              '${AppTranslations.translate('welcome', locale)}, ${user?.name ?? ''} ${user?.surname ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${AppTranslations.translate('role_label', locale)}: ${AppTranslations.translate(user?.role ?? '', locale)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: SizeTokens.p32),
            const Text('Yönetici Özellikleri Yakında...'),
          ],
        ),
      ),
    );
  }
}
