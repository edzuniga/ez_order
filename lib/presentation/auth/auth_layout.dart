import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}
