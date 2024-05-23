import 'package:ez_order_ezr/data/menu_item_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'menu_provider.g.dart';

@Riverpod(keepAlive: true)
class MenuItemPedidoList extends _$MenuItemPedidoList {
  @override
  List<MenuItemModel> build() {
    return [];
  }

  //poblar el listado con lo que viene de supa
  void addMenuItem(MenuItemModel modelo) {
    state = [...state, modelo];
  }

  //Remover del listado
  void removeMenuItem(MenuItemModel modelo) {
    state.removeWhere((element) => element.idMenu == modelo.idMenu);
  }

  void resetMenuItem() {
    state.clear();
  }
}
