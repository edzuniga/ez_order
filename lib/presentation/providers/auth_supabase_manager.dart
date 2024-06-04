import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
import 'package:ez_order_ezr/utils/secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Future<int> chechAuthStatus() async {
    //1 = AUTHENTICATED
    //2 = NOT AUTHENTICATED
    final supabase = getSupabaseInstance();
    final session = supabase.auth.currentSession;

    if (session != null) {
      state = true;
      return 1;
    } else {
      state = false;
      return 2;
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
          .select('email, nombre, rol, id_restaurante')
          .eq('uuid_usuario', userUuid)
          .single();

      //Guardar esta info del usuario en el dispositivo
      final SecureStorage secureStorage = SecureStorage();
      await secureStorage.setUserEmail(userData['email']);
      await secureStorage.setUserNombre(userData['nombre']);
      await secureStorage.setUserRol(userData['rol']);
      await secureStorage.setUserIdRestaurante(userData['id_restaurante']);

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
      //Guardar esta info del usuario en el dispositivo
      final SecureStorage secureStorage = SecureStorage();
      await secureStorage.getAllValues();
      state = false;
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }
}
