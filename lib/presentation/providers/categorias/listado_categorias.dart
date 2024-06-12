import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ez_order_ezr/data/categoria_modelo.dart';
part 'listado_categorias.g.dart';

@Riverpod(keepAlive: true)
class ListadoCategorias extends _$ListadoCategorias {
  @override
  List<CategoriaModelo> build() {
    return [];
  }

  void setCategorias(List<CategoriaModelo> cat) {
    state = [...cat];
  }

  void resetCategorias() {
    state = [];
  }
}
