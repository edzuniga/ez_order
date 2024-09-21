import 'package:animate_do/animate_do.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import 'package:ez_order_ezr/presentation/dashboard/modals/ticket_number_modal.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/num_pedido_actual.dart';
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
    Size screenSize = MediaQuery.of(context).size;
    final selectedPageTitle = ref.watch(dashboardPageTitleProvider);
    final selectedPageIndex = ref.watch(dashboardPageIndexProvider);
    final numOrdenActual = ref.watch(numeroPedidoActualProvider);
    final datosPublicos = ref.watch(userPublicDataProvider);
    DateTime hoy = DateTime.now();
    String hoyFormateado = DateFormat.yMMMd('es').format(hoy);

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
          //Mostrar Botón de TICKET para Pantalla de Agregar Pedido
          selectedPageIndex == 1
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // print('button pressed');
                      await _changeTicketNumber();
                    },
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.kGeneralPrimaryOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '# Ticket: $numOrdenActual',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          //Mostrar La fecha formateada para Pantalla de Reportes View
          selectedPageIndex == 2
              ? screenSize.width >= 700
                  ? Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE8E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Estadísticas del día de hoy: $hoyFormateado',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : const SizedBox()
              : const SizedBox(),
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
          datosPublicos['rol'] == '2' || datosPublicos['rol'] == '1'
              ? OutlinedButton.icon(
                  onPressed: () {
                    context.pushNamed(Routes.caja);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 1.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.point_of_sale_rounded,
                    color: AppColors.kGeneralPrimaryOrange,
                    size: 15,
                  ),
                  label: Text(
                    'Inicio/Cierre',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox(),
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

  Future<void> _changeTicketNumber() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: TicketModal(),
      ),
    );
  }
}
