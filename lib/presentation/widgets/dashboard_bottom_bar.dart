import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardBottomNavigationBar extends ConsumerWidget {
  const DashboardBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageIndex = ref.watch(dashboardPageIndexProvider);
    return BottomNavigationBar(
      onTap: (index) {
        ref.read(dashboardPageIndexProvider.notifier).changePageIndex(index);
      },
      currentIndex: selectedPageIndex,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedItemColor: AppColors.kGeneralPrimaryOrange,
      unselectedItemColor: AppColors.kTextPrimaryBlack,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), label: 'Pedidos'),
        BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.kitchenSet), label: 'Cocina'),
        BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check_outlined), label: 'Reportes'),
        BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_outlined),
            label: 'Administración'),
      ],
    );
  }
}
