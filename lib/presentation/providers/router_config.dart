import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ez_order_ezr/presentation/caja/caja_page.dart';
import 'package:ez_order_ezr/presentation/dashboard/gastos_caja_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/pedidos/en_preparacion_page.dart';
import 'package:ez_order_ezr/presentation/dashboard/pedidos/entregados_page.dart';
import 'package:ez_order_ezr/presentation/auth/auth_layout.dart';
import 'package:ez_order_ezr/presentation/auth/login_view.dart';
import 'package:ez_order_ezr/presentation/auth/recovery_view.dart';
import 'package:ez_order_ezr/presentation/cocina/cocina_page.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/dashboard/agregar_pedido_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/dashboard_layout.dart';
import 'package:ez_order_ezr/presentation/dashboard/facturacion_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/pedidos_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/reportes_view.dart';
import 'package:ez_order_ezr/presentation/error_page.dart';
import 'package:ez_order_ezr/presentation/providers/auth_supabase_manager.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';
part 'router_config.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      //Auth routes
      ShellRoute(
        builder: (context, state, child) => AuthLayout(child: child),
        routes: [
          GoRoute(
            name: Routes.login,
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const LoginView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          GoRoute(
            name: Routes.recovery,
            path: '/recovery',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const RecoveryView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
        ],
      ),
      //Dashboard routes
      ShellRoute(
        builder: (context, state, _) => const DashboardLayout(),
        routes: [
          GoRoute(
            name: Routes.pedidos,
            path: '/pedidos',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PedidosView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          GoRoute(
            name: Routes.agregarPedido,
            path: '/agregar_pedido',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AgregarPedidoView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          GoRoute(
            name: Routes.reportes,
            path: '/reportes',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ReportesView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          GoRoute(
            name: Routes.facturacion,
            path: '/facturacion',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const FacturacionView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
          GoRoute(
            name: Routes.gastosCaja,
            path: '/gastos_caja',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const GastosCajaView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        name: Routes.cocina,
        path: '/cocina',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CocinaPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
      GoRoute(
        name: Routes.enPreparacion,
        path: '/en_preparacion',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const EnPreparacionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
      GoRoute(
        name: Routes.entregados,
        path: '/pedidos_entregados',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const EntregadosPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
      GoRoute(
        name: Routes.caja,
        path: '/caja',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CajaPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => CustomTransitionPage(
      child: const ErrorPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
    ),
    redirect: (context, state) {
      //Obtener el estado de autenticación
      final isAuthenticated = ref.read(authManagerProvider);

      //Rutas accesibles e inaccesibles dependiendo autenticación
      const accessibleRoutes = ['/', '/recovery'];
      const dashboardRoutes = [
        '/pedidos',
        '/agregar_pedido',
        '/reportes',
        '/facturacion',
        '/gastos_caja',
      ];
      const unaccessibleRoutes = [
        '/cocina',
        '/pedidos_entregados',
        '/en_preparacion',
        '/caja',
      ];

      WidgetsBinding.instance.addPostFrameCallback((v) {
        final pageIndexManager = ref.read(dashboardPageIndexProvider.notifier);

        if (dashboardRoutes.contains(state.matchedLocation)) {
          switch (state.matchedLocation) {
            case '/pedidos':
              pageIndexManager.changePageIndex(0);
              break;
            case '/agregar_pedido':
              pageIndexManager.changePageIndex(1);
              break;
            case '/reportes':
              pageIndexManager.changePageIndex(2);
              break;
            case '/facturacion':
              pageIndexManager.changePageIndex(3);
              break;
            case '/gastos_caja':
              pageIndexManager.changePageIndex(4);
              break;
          }
        }
      });

      //Permitir acceso a AUTH sin autenticación
      if (!isAuthenticated &&
          (accessibleRoutes.contains(state.matchedLocation))) {
        return null;
      }

      // Si el usuario no está autenticado y está intentando acceder a una
      // ruta que requiere autenticación
      if (!isAuthenticated &&
          (unaccessibleRoutes.contains(state.matchedLocation))) {
        // Redirige al usuario a la pantalla de login
        return '/';
      }

      return null;
    },
  );
}
