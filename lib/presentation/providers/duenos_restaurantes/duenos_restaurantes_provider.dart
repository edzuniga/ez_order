import 'package:ez_order_ezr/data/restaurante_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'duenos_restaurantes_provider.g.dart';

@Riverpod(keepAlive: true)
class DuenosResManager extends _$DuenosResManager {
  @override
  List<RestauranteModelo> build() {
    return [];
  }

  void addRestaurante(RestauranteModelo restaurante) {
    state = [...state, restaurante];
  }

  void removeRestaurante(RestauranteModelo restaurante) {
    state.removeWhere((res) => res.idRestaurante == restaurante.idRestaurante);
  }

  void resetLlistRestaurantes() {
    state = [];
  }

  Future<List<RestauranteModelo>> obtenerRestaurantesPorDueno() async {
    String userUuid =
        ref.read(userPublicDataProvider)['uuid_usuario'].toString();
    await ref
        .read(supabaseManagementProvider.notifier)
        .obtenerIdRestaurantesPorDueno(userUuid);
    return state;
  }
}
