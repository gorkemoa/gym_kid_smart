import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_view_model.dart';
import '../../core/responsive/size_tokens.dart';
import '../login/login_view.dart';

class HomeParentView extends StatelessWidget {
  const HomeParentView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginViewModel>().data?.data;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Veli Paneli'),
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
              'Hoş geldin, ${user?.name ?? ''} ${user?.surname ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Rol: Veli', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: SizeTokens.p32),
            const Text('Veli Özellikleri Yakında...'),
          ],
        ),
      ),
    );
  }
}
