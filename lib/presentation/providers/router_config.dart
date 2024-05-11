import 'package:ez_order_ezr/presentation/auth/auth_layout.dart';
import 'package:ez_order_ezr/presentation/auth/login_view.dart';
import 'package:ez_order_ezr/presentation/auth/recovery_view.dart';
import 'package:ez_order_ezr/presentation/config/routes.dart';
import 'package:ez_order_ezr/presentation/dashboard/administracion_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/cocina_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/dashboard_layout.dart';
import 'package:ez_order_ezr/presentation/dashboard/pedidos_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/reportes_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
            name: Routes.cocina,
            path: '/cocina',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const CocinaView(),
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
            name: Routes.administracion,
            path: '/administracion',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AdminView(),
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
    ],
  );
}
