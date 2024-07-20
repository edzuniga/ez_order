import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/menu_provider.dart';
part 'descuento_provider.g.dart';

@Riverpod(keepAlive: true)
class DescuentoPedidoActual extends _$DescuentoPedidoActual {
  @override
  double build() {
    return 0.0;
  }

  void actualizarDescuento(double newValue) {
    state = newValue;
    ref.read(menuItemPedidoListProvider.notifier).hacerCalculosDelPedido();
  }

  void resetDescuento() {
    state = 0.0;
  }
}
