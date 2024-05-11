import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dashboard_page_title.g.dart';

@Riverpod(keepAlive: true)
class DashboardPageTitle extends _$DashboardPageTitle {
  @override
  String build() {
    return 'Pedidos';
  }

  void changePageTitle(String title) {
    state = title;
  }
}
