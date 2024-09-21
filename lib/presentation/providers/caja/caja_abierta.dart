import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/restaurante_caja_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'caja_abierta.g.dart';

@riverpod
class CajaAbierta extends _$CajaAbierta {
  @override
  Future<bool> build() async {
    int? idRes = ref.read(cajaRestauranteSeleccionadoProvider).idRestaurante;
    if (idRes != null) {
      final cajaAbierta = await ref
          .read(supabaseManagementProvider.notifier)
          .getCajaAbierta(idRes);
      return cajaAbierta.abierto;
    }
    return false;
  }

  //Función para refrescar el provider (listado)
  Future<void> refresh() {
    return ref.refresh(cajaAbiertaProvider.future);
  }
}
