import 'package:animate_do/animate_do.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/providers/dashboard_page_title.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class CustomAppBar extends ConsumerStatefulWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  bool _tryingLogout = false;

  @override
  Widget build(BuildContext context) {
    final selectedPageTitle = ref.watch(dashboardPageTitleProvider);
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Gap(15),
          Text(
            selectedPageTitle,
            style: GoogleFonts.inter(
              fontSize: 20,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              _tryingLogout ? null : await _tryLogout();
            },
            tooltip: 'Cerrar sesión',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.kGeneralPrimaryOrange,
            ),
            icon: _tryingLogout
                ? SpinPerfect(
                    infinite: true,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
          ),
          const Gap(15),
        ],
      ),
    );
  }

  Future<void> _tryLogout() async {
    setState(() => _tryingLogout = true);
    final authManager = ref.read(authManagerProvider.notifier);
    String tryLogoutMessage = await authManager.tryLogout();
    setState(() => _tryingLogout = false);
    if (tryLogoutMessage == 'success') {
      if (!mounted) return;
      context.goNamed(Routes.login);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.kGeneralErrorColor,
          content: Text(
            tryLogoutMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
