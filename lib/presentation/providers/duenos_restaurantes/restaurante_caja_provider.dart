import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ez_order_ezr/data/restaurante_modelo.dart';

part 'restaurante_caja_provider.g.dart';

@Riverpod(keepAlive: true)
class CajaRestauranteSeleccionado extends _$CajaRestauranteSeleccionado {
  @override
  RestauranteModelo build() {
    return RestauranteModelo(
      createdAt: DateTime.now(),
      nombreRestaurante: 'No ha seleccionado...',
    );
  }

  void setRestauranteSeleccionado(RestauranteModelo res) {
    state = res;
  }

  void resetRestauranteSeleccionado() {
    state = RestauranteModelo(
      createdAt: DateTime.now(),
      nombreRestaurante: 'No ha seleccionado...',
    );
  }
}
