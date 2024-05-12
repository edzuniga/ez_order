import 'package:ez_order_ezr/presentation/providers/supabase_instance.dart';
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
    return ref.watch(supabaseInstanceProvider);
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
      await supaInstance.auth.signInWithPassword(
        email: email,
        password: password,
      );
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
      state = false;
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }
}
