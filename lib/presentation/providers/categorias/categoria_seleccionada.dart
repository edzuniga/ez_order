import 'package:ez_order_ezr/data/categoria_modelo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'categoria_seleccionada.g.dart';

@Riverpod(keepAlive: true)
class CategoriaActual extends _$CategoriaActual {
  @override
  CategoriaModelo build() {
    return CategoriaModelo(
      idCategoria: 0,
      nombreCategoria: 'Seleccione categoría...',
      idRestaurante: 0,
      activo: true,
    );
  }

  void setCategoriaActual(CategoriaModelo categoria) {
    state = state.copyWith(
      idCategoria: categoria.idCategoria,
      nombreCategoria: categoria.nombreCategoria,
      idRestaurante: categoria.idRestaurante,
      activo: categoria.activo,
    );
  }

  void resetCategoriaSeleccionada() {
    state = CategoriaModelo(
      idCategoria: 0,
      nombreCategoria: 'Seleccione categoría...',
      idRestaurante: 0,
      activo: true,
    );
  }
}
