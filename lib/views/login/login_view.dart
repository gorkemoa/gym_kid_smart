import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../viewmodels/login_view_model.dart';
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeTokens.p32 * 2),
              // Mascot or Welcome Illustration
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SizeTokens.r24),
                ),
                child: const Center(
                  child: Icon(Icons.school, size: 80, color: Colors.white),
                ),
              ),
              SizedBox(height: SizeTokens.p32),
              Text(
                'Giriş Yap',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: SizeTokens.p8),
              Text(
                'Çocuğunuzun gelişimini takip edin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
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
  }
}

class _PoweredBy extends StatelessWidget {
  const _PoweredBy();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Powered by',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
        SizedBox(height: SizeTokens.p4),
        // Use the logo from assets if available, otherwise text
        Image.asset(
          'assets/smartmetrics-logo.png',
          height: 20,
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
