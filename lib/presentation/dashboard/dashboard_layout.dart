import 'package:ez_order_ezr/presentation/widgets/dashboard_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ez_order_ezr/presentation/widgets/custom_appbar.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:gap/gap.dart';

class DashboardLayout extends ConsumerWidget {
  const DashboardLayout({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.kGeneralOrangeBg, AppColors.kGeneralFadedOrange],
          stops: [0.0, 1.0],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomAppBar(),
                const Gap(20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: child,
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
          bottomNavigationBar: const DashboardBottomNavigationBar(),
        ),
      ),
    );
  }
}
