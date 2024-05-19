import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de error'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Página de error provisional'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.goNamed(Routes.login),
              child: const Text('Ir a inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
