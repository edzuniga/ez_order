import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:random_string/random_string.dart';
import 'package:ez_order_ezr/data/pedido_model.dart';
part 'pedido_actual_provider.g.dart';

@riverpod
class PedidoActual extends _$PedidoActual {
  @override
  PedidoModel build() {
    //Obtener el id restaurante del usuario
    int idRes = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    return PedidoModel(
      idRestaurante: idRes,
      descuento: 0.0,
      impuestos: 0.0,
      subtotal: 0.0,
      total: 0.0,
      importeExonerado: 0.0,
      importeExento: 0.0,
      importeGravado: 0.0,
      isvAplicado: '15%',
      orden: randomNumeric(15),
    );
  }

  //Actualizar la info del pedido actual
  void actualizarInfo({
    required double subtotl,
    required double isv,
    required double descuento,
    required double total,
    required double importeExonerado,
    required double importeExento,
    required double importeGravado,
  }) {
    state = state.copyWith(
      subtotal: subtotl,
      impuestos: isv,
      descuento: descuento,
      importeExonerado: importeExonerado,
      importeExento: importeExento,
      importeGravado: importeGravado,
      total: total,
    );
  }
}
