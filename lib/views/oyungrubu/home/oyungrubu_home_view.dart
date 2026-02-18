import 'package:flutter/material.dart';

class OyunGrubuHomeView extends StatelessWidget {
  const OyunGrubuHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Grubu')),
      body: const Center(child: Text('Oyun Grubu Modülü Çok Yakında!')),
    );
  }
}
