import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:ez_order_ezr/presentation/widgets/mobile_appbar.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_view.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/presentation/widgets/dashboard_bottom_bar.dart';
import 'package:ez_order_ezr/utils/secure_storage.dart';
import 'package:ez_order_ezr/presentation/widgets/custom_appbar.dart';
import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  const DashboardLayout({super.key});

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) async {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final checkAuthResponse =
        await ref.read(authManagerProvider.notifier).checkAuthStatus();
    if (!checkAuthResponse) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Debe iniciar sesión',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      context.goNamed(Routes.login);
    } else {
      await _getUserData();
      setState(() {});
    }
  }

  Future<void> _getUserData() async {
    //Obtener los datos de facturación y guardarlos en el provider
    await ref.read(supabaseManagementProvider.notifier).getDatosFactura();
    SecureStorage secureStorage = SecureStorage();
    Map<String, String> userDataMap = await secureStorage.getAllValues();
    //Guardar los datos en un provider
    ref.read(userPublicDataProvider.notifier).setUserData(userDataMap);
    //* 1->admin 2->dueño 3->empleado 4->cocina
    if (userDataMap.isNotEmpty) {
      switch (ref.read(userPublicDataProvider)['rol']) {
        //case para cocina
        case '4':
          if (!mounted) return;
          //Navegar a la pestaña de COCINA
          context.pushNamed(Routes.cocina);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    bool chequeoPortraitYNoWeb =
        (!kIsWeb && orientation == Orientation.portrait);
    final Widget view = ref.watch(dashboardViewProvider);

    if (chequeoPortraitYNoWeb) {
      return mobileAndPortraitView(view);
    }
    return webAndLandscapeView(view);
  }

  //View para WEB y Landscape en general
  Widget webAndLandscapeView(Widget view) {
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

  //View para MÓVILES y Portrait
  Widget mobileAndPortraitView(Widget view) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MobileAppBar(),
            Expanded(
              child: view,
            ),
          ],
        ),
        bottomNavigationBar: const DashboardBottomNavigationBar(),
      ),
    );
  }
}
