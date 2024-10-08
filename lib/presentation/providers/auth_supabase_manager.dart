import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ez_order_ezr/presentation/providers/facturacion/detalles_pedido_para_view.dart';
import 'package:ez_order_ezr/presentation/providers/duenos_restaurantes/reportes_valores_provider.dart';
import 'package:ez_order_ezr/presentation/providers/categorias/categoria_seleccionada.dart';
import 'package:ez_order_ezr/presentation/providers/dashboard_page_index.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/datos_factura_provider.dart';
import 'package:ez_order_ezr/presentation/providers/facturacion/pedido_para_view.dart';
import 'package:ez_order_ezr/presentation/providers/categorias/listado_categorias.dart';
import 'package:ez_order_ezr/presentation/providers/menus_providers/cliente_actual_provider.dart';
import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:ez_order_ezr/utils/secure_storage.dart';
part 'auth_supabase_manager.g.dart';

@Riverpod(keepAlive: true)
class AuthManager extends _$AuthManager {
  @override
  bool build() {
    return false;
  }

  SupabaseClient getSupabaseInstance() {
    return ref.watch(supabaseManagementProvider);
  }

  //Check auth status
  Future<bool> checkAuthStatus() async {
    final supabase = getSupabaseInstance();
    final session = supabase.auth.currentSession;

    if (session != null) {
      state = true;
      return state;
    } else {
      state = false;
      return state;
    }
  }

  //try login
  Future<String> tryLogin({required email, required password}) async {
    final supaInstance = getSupabaseInstance();
    try {
      AuthResponse res = await supaInstance.auth.signInWithPassword(
        email: email,
        password: password,
      );
      //Obtener el uuid del usuario que intenta el login
      String userUuid = res.user!.id;

      //Obtener los datos de la tabla pública de usuarios
      final userData = await supaInstance
          .from('usuarios_info')
          .select('email, nombre, rol, id_restaurante, uuid_usuario')
          .eq('uuid_usuario', userUuid)
          .limit(1)
          .single();

      //Guardar esta info del usuario en el dispositivo
      final SecureStorage secureStorage = SecureStorage();
      await secureStorage.setUserEmail(userData['email']);
      await secureStorage.setUserNombre(userData['nombre']);
      await secureStorage.setUserRol(userData['rol']);
      await secureStorage.setUserIdRestaurante(userData['id_restaurante']);
      await secureStorage.setUserUuIdUser(userData['uuid_usuario']);

      Map<String, String> userDataMap = await secureStorage.getAllValues();
      //Guardar los datos en un provider
      ref.read(userPublicDataProvider.notifier).setUserData(userDataMap);

      state = true;
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  //try logout
  Future<String> tryLogout() async {
    final supaInstance = getSupabaseInstance();
    try {
      await supaInstance.auth.signOut();
      //Resetear todos los providers importantes
      ref.read(dashboardPageIndexProvider.notifier).changePageIndex(0);
      ref.read(categoriaActualProvider.notifier).resetCategoriaSeleccionada();
      ref.read(listadoCategoriasProvider.notifier).resetCategorias();
      ref.read(valoresReportesProvider.notifier).resetValores();
      ref.read(datosFacturaManagerProvider.notifier).resetDatosFactura();
      ref.read(detallesParaPedidoViewProvider.notifier).resetListado();
      ref.read(pedidoParaViewProvider.notifier).resetPedidoParaView();
      ref.read(clientePedidoActualProvider.notifier).resetClienteOriginal();
      ref.read(dashboardPageIndexProvider.notifier).resetPageIndex();
      //Eliminar la info de Secure Storage
      final SecureStorage secureStorage = SecureStorage();
      await secureStorage.deleteAllValues();
      ref.read(userPublicDataProvider.notifier).eraseUserData();
      state = false;
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }
}
