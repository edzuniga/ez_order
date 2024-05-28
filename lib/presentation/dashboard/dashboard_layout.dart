import 'package:ez_order_ezr/presentation/providers/dashboard_view.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/widgets/dashboard_bottom_bar.dart';
import 'package:ez_order_ezr/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ez_order_ezr/presentation/widgets/custom_appbar.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:gap/gap.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  const DashboardLayout({super.key});

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    SecureStorage secureStorage = SecureStorage();
    Map<String, String> userDataMap = await secureStorage.getAllValues();
    //Guardar los datos en un provider
    ref.read(userPublicDataProvider.notifier).setUserData(userDataMap);
    //TODO montar la condiciones dependiendo el rol
    //* 1->admin 2->dueño 3->empleado 4->cocina
    if (userDataMap.isNotEmpty) {
      switch (userDataMap['rol']) {
        //case para admins
        case '1':
          break;

        //case para dueños
        case '2':
          break;

        //case para empleados
        case '3':
          break;

        //case para cocina
        case '4':
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget view = ref.watch(dashboardViewProvider);
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
                const Gap(8),
                Expanded(
                  child: view,
                ),
              ],
            ),
          ),
          bottomNavigationBar: const DashboardBottomNavigationBar(),
        ),
      ),
    );
  }
}
