import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../viewmodels/login_view_model.dart';
import '../../home_admin/home_admin_view.dart';
import '../../home_teacher/home_teacher_view.dart';
import '../../home_parent/home_parent_view.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            TextField(
              controller: viewModel.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: SizeTokens.p16),
            TextField(
              controller: viewModel.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Şifre',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            if (viewModel.errorMessage != null) ...[
              SizedBox(height: SizeTokens.p16),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Colors.white, fontSize: SizeTokens.f12),
              ),
            ],
            SizedBox(height: SizeTokens.p24),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final success = await viewModel.login();
                      if (success && context.mounted) {
                        final role = viewModel.data?.data?.role;

                        Widget targetView;
                        // Determine which view to navigate based on role
                        if (role == 'superadmin' || role == 'admin') {
                          targetView = const HomeAdminView();
                        } else if (role == 'teacher') {
                          targetView = const HomeTeacherView();
                        } else {
                          targetView = const HomeParentView();
                        }

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => targetView),
                        );
                      }
                    },
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Giriş Yap'),
            ),
          ],
        );
      },
    );
  }
}
