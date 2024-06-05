import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ez_order_ezr/data/reporte_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
part 'reportes_valores_provider.g.dart';

@Riverpod(keepAlive: true)
class ValoresReportes extends _$ValoresReportes {
  @override
  ReporteModelo build() {
    return ReporteModelo(
      cantMenu: 0,
      cantPedidosDiarios: 0,
      ingresosDiarios: 0.0,
    );
  }

  void setValores(ReporteModelo reporte) {
    state = reporte;
  }

  void resetValores() {
    state = ReporteModelo(
      cantMenu: 0,
      cantPedidosDiarios: 0,
      ingresosDiarios: 0.0,
    );
  }

  Future<void> hacerCalculosReporte(int idRestaurante) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final supa = ref.read(supabaseManagementProvider);
    try {
      //Cantidad de Productos en el MENÚ
      final cantidadMenu = await supa
          .from('menus')
          .select()
          .eq('id_restaurante', idRestaurante)
          .count(CountOption.exact);
      //Cantidad de PEDIDOS en este día
      final cantidadPedidos = await supa
          .from('pedidos')
          .select()
          .eq('id_restaurante', idRestaurante)
          .gte(
            'created_at',
            startOfDay,
          )
          .count(CountOption.exact);
      //Ingresos totales del día
      double ingresosHoyTotal = 0.0;
      List<Map<String, dynamic>> ingresosHoyRes = await supa
          .from('pedidos')
          .select()
          .eq('id_restaurante', idRestaurante)
          .gte(
            'created_at',
            startOfDay,
          );
      for (Map<String, dynamic> map in ingresosHoyRes) {
        if (map.containsKey('total')) {
          ingresosHoyTotal += map['total'];
        }
      }

      state = state.copyWith(
        cantMenu: cantidadMenu.count,
        cantPedidosDiarios: cantidadPedidos.count,
        ingresosDiarios: ingresosHoyTotal,
      );
    } catch (e) {
      rethrow;
    }
  }
}
