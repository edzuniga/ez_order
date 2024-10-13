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
      clientes: 0,
      totalEfectivo: 0.0,
      totalTarjeta: 0.0,
      totalTransferencia: 0.0,
      cantEfectivo: 0,
      cantTarjeta: 0,
      cantTransferencia: 0,
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
      clientes: 0,
      totalEfectivo: 0.0,
      totalTarjeta: 0.0,
      totalTransferencia: 0.0,
      cantEfectivo: 0,
      cantTarjeta: 0,
      cantTransferencia: 0,
    );
  }

  Future<void> hacerCalculosReporte(int idRestaurante,
      {DateTime? fechaCierreAnterior}) async {
    final today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    if (fechaCierreAnterior != null) {
      startOfDay = fechaCierreAnterior;
    }
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
      double totalEfectivo = 0.0;
      double totalTarjeta = 0.0;
      double totalTransferencia = 0.0;
      int cantEfectivo = 0;
      int cantTarjeta = 0;
      int cantTransferencia = 0;

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
          //Sumar los totales en efectivo
          if (map['id_metodo_pago'] == 1) {
            totalEfectivo += map['total'];
            cantEfectivo++;
          }
          //Sumar los totales en tarjeta
          if (map['id_metodo_pago'] == 2) {
            totalTarjeta += map['total'];
            cantTarjeta++;
          }
          //Sumar los totales en transferencia
          if (map['id_metodo_pago'] == 3) {
            totalTransferencia += map['total'];
            cantTransferencia++;
          }
        }
      }
      //Cantidad de clientes del restaurante
      final cantidadClientes = await supa
          .from('clientes')
          .select()
          .eq('id_restaurante', idRestaurante)
          .count(CountOption.exact);

      state = state.copyWith(
        cantMenu: cantidadMenu.count,
        cantPedidosDiarios: cantidadPedidos.count,
        ingresosDiarios: ingresosHoyTotal,
        clientes: cantidadClientes.count,
        totalEfectivo: totalEfectivo,
        totalTarjeta: totalTarjeta,
        totalTransferencia: totalTransferencia,
        cantEfectivo: cantEfectivo,
        cantTarjeta: cantTarjeta,
        cantTransferencia: cantTransferencia,
      );
    } catch (e) {
      rethrow;
    }
  }
}
