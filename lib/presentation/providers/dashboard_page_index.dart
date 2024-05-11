import 'package:ez_order_ezr/presentation/providers/dashboard_page_title.dart';
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
i = 1 -> Cocina
i = 2 -> Reportes
i = 3 -> Administración
*/

  void changePageIndex(int i) {
    state = i;
    //Change page title
    String pageTitle = '';
    switch (i) {
      case 0:
        pageTitle = 'Pedidos';
        break;
      case 1:
        pageTitle = 'Cocina';
        break;
      case 2:
        pageTitle = 'Reportes';
        break;
      case 3:
        pageTitle = 'Administración';
        break;
    }
    ref.read(dashboardPageTitleProvider.notifier).changePageTitle(pageTitle);
  }
}
