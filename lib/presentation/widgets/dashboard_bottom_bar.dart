import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';

class DashboardBottomNavigationBar extends ConsumerWidget {
  const DashboardBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedPageIndex = ref.watch(dashboardPageIndexProvider);

    return BottomNavigationBar(
      onTap: (index) {
        ref.read(dashboardPageIndexProvider.notifier).changePageIndex(index);
        /*
        i = 0 -> Pedidos
        i = 1 -> Agregar Pedido
        i = 2 -> Reportes
        i = 3 -> Facturación
        i = 4 -> Gastos de Caja
        */
        String pageTitle = '';
        switch (index) {
          case 0:
            pageTitle = Routes.pedidos;
            break;
          case 1:
            pageTitle = Routes.agregarPedido;
            break;
          case 2:
            pageTitle = Routes.reportes;
            break;
          case 3:
            pageTitle = Routes.facturacion;
            break;
          case 4:
            pageTitle = Routes.gastosCaja;
            break;
        }
        navigateTo(context, pageTitle);
      },
      currentIndex: selectedPageIndex,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedItemColor: AppColors.kGeneralPrimaryOrange,
      unselectedItemColor: AppColors.kTextPrimaryBlack,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/bolsa-compras.svg',
              height: 20,
              width: 20,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/bolsa-compras.svg',
              height: 22,
              width: 22,
              colorFilter: const ColorFilter.mode(
                  AppColors.kGeneralPrimaryOrange, BlendMode.srcIn),
            ),
            label: 'Pedidos'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/carrito.svg',
              height: 20,
              width: 20,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/carrito.svg',
              height: 22,
              width: 22,
              colorFilter: const ColorFilter.mode(
                  AppColors.kGeneralPrimaryOrange, BlendMode.srcIn),
            ),
            label: 'Agregar pedido'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/reportes.svg',
              height: 20,
              width: 20,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/reportes.svg',
              height: 22,
              width: 22,
              colorFilter: const ColorFilter.mode(
                  AppColors.kGeneralPrimaryOrange, BlendMode.srcIn),
            ),
            label: 'Reportes'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/facturacion.svg',
              height: 20,
              width: 20,
              colorFilter:
                  const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/facturacion.svg',
              height: 22,
              width: 22,
              colorFilter: const ColorFilter.mode(
                  AppColors.kGeneralPrimaryOrange, BlendMode.srcIn),
            ),
            label: 'Facturación'),
        const BottomNavigationBarItem(
            icon: Icon(
              Icons.point_of_sale,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.point_of_sale,
              color: AppColors.kGeneralPrimaryOrange,
              size: 22,
            ),
            label: 'Gastos Caja'),
      ],
    );
  }

  void navigateTo(BuildContext ctx, String pageName) {
    ctx.goNamed(pageName);
  }
}
