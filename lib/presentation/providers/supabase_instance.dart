import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'supabase_instance.g.dart';

@Riverpod(keepAlive: true)
class SupabaseManagement extends _$SupabaseManagement {
  @override
  SupabaseClient build() {
    final instance = Supabase.instance.client;
    return instance;
  }

  //MÉTODOS PARA EL MENÚ
  Future<String> addMenuItem(MenuItemModel menuItemModel) async {
    Map menuItemMap = menuItemModel.toJson();
    try {
      var newMenuItemInfo =
          await state.from('menu').insert(menuItemMap).select('id_menu');
      var newMenuItemId = newMenuItemInfo.first['id_menu'];
      print(newMenuItemId);
      return 'success';
    } on PostgrestException catch (e) {
      print(e);
      return e.message;
    }
  }
}
