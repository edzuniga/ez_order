import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/presentation/dashboard/pedidos_view.dart';
part 'dashboard_view.g.dart';

@Riverpod(keepAlive: true)
class DashboardView extends _$DashboardView {
  @override
  Widget build() {
    return const PedidosView();
  }

  void changeDashboardView(Widget view) {
    state = view;
  }
}
