import 'package:animate_do/animate_do.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/num_pedido_actual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    final selectedPageTitle = ref.watch(dashboardPageTitleProvider);
    final selectedPageIndex = ref.watch(dashboardPageIndexProvider);
    final numOrdenActual = ref.watch(numeroPedidoActualProvider);
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
          selectedPageIndex == 1
              ? Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '# Orden Actual: $numOrdenActual',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              : const SizedBox(),
          const Gap(10),
          IconButton(
            onPressed: () {
              if (!_isFullScreen) {
                setState(() {
                  _isFullScreen = true;
                  SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky);
                });
              } else {
                setState(() {
                  _isFullScreen = false;
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                });
              }
            },
            tooltip: '¿Pantalla completa?',
            style: IconButton.styleFrom(
                backgroundColor: AppColors.kIconGrayishIcon),
            icon: Icon(
              !_isFullScreen ? Icons.fullscreen : Icons.fullscreen_exit,
              color: Colors.white,
            ),
          ),
          const Gap(10),
          OutlinedButton.icon(
            onPressed: () {
              context.pushNamed(Routes.cocina);
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.soup_kitchen_sharp,
              color: AppColors.kGeneralPrimaryOrange,
              size: 15,
            ),
            label: Text(
              'Cocina',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Gap(20),
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
