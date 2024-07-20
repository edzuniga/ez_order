import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/menu_provider.dart';
import 'package:ez_order_ezr/utils/metodo_pago_enum.dart';
part 'metodo_pago_actual.g.dart';

@Riverpod(keepAlive: true)
class MetodoPagoActual extends _$MetodoPagoActual {
  @override
  MetodoDePagoEnum build() {
    return MetodoDePagoEnum.efectivo;
  }

  void updateMetodoPago(MetodoDePagoEnum m) {
    state = m;
    ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
  }

  void resetMetodoDePago() {
    state = MetodoDePagoEnum.efectivo;
  }
}
