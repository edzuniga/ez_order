import 'package:ez_order_ezr/presentation/dashboard/administracion_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/agregar_pedido_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/pedidos_view.dart';
import 'package:ez_order_ezr/presentation/dashboard/reportes_view.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_title.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_view.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dashboard_page_index.g.dart';

@Riverpod(keepAlive: true)
class DashboardPageIndex extends _$DashboardPageIndex {
  @override
  int build() {
    return 0;
  }

/*
i = 0 -> Pedidos
i = 1 -> Agregar Pedido
i = 2 -> Reportes
i = 3 -> Administración
*/

  void changePageIndex(int i) {
    state = i;
    //Change page title
    String pageTitle = '';
    Widget view = Container();
    switch (i) {
      case 0:
        pageTitle = 'Pedidos';
        view = const PedidosView();
        break;
      case 1:
        pageTitle = 'Agregar Pedido';
        view = const AgregarPedidoView();
        break;
      case 2:
        pageTitle = 'Reportes';
        view = const ReportesView();
        break;
      case 3:
        pageTitle = 'Administración';
        view = const AdminView();
        break;
    }
    //Dependiendo el index se ajusta el title y view
    ref.read(dashboardPageTitleProvider.notifier).changePageTitle(pageTitle);
    ref.read(dashboardViewProvider.notifier).changeDashboardView(view);
  }
}
