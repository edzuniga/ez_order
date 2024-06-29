import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';

class CocinaAppBar extends ConsumerStatefulWidget {
  const CocinaAppBar({
    super.key,
  });

  @override
  ConsumerState<CocinaAppBar> createState() => _CocinaAppBarState();
}

class _CocinaAppBarState extends ConsumerState<CocinaAppBar> {
  bool _tryingLogout = false;
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
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
            'Cocina',
            style: GoogleFonts.inter(
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Text(
            'Pedidos por entregar',
            style: GoogleFonts.roboto(
              color: AppColors.kTextPrimaryBlack,
              fontSize: 18.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Gap(10),
          (!kIsWeb)
              ? IconButton(
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
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge);
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
                )
              : const SizedBox(),
          const Gap(10),
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
