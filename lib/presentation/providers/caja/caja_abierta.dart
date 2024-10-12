import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';

part 'caja_abierta.g.dart';

@riverpod
class CajaAbierta extends _$CajaAbierta {
  @override
  bool build() {
    return false;
  }

  Future<bool> chequearSiCajaEstaAbierta() async {
    //Obtener el id del restaurante
    int userIdRestaurante = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());

    //setear el valor
    state = await ref
        .read(supabaseManagementProvider.notifier)
        .cajaCerradaoAbierta(userIdRestaurante);
    return state;
  }

  resetCajaStatus() {
    state = false;
  }
}
