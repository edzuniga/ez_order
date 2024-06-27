import 'package:ez_order_ezr/data/datos_factura_modelo.dart';
import 'package:ez_order_ezr/presentation/providers/users_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'datos_factura_provider.g.dart';

@Riverpod(keepAlive: true)
class DatosFacturaManager extends _$DatosFacturaManager {
  @override
  DatosFacturaModelo build() {
    int resId = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    return DatosFacturaModelo(
      idDatosFactura: 0,
      idRestaurante: resId,
      nombreNegocio: '',
      rtn: '',
      direccion: '',
      correo: '',
      telefono: '',
      cai: '',
      rangoInicial: 0,
      rangoFinal: 0,
      fechaLimite: null,
    );
  }

  void setDatosFactura(DatosFacturaModelo datos) {
    state = datos;
  }

  void resetDatosFactura() {
    int resId = int.parse(
        ref.read(userPublicDataProvider)['id_restaurante'].toString());
    state = DatosFacturaModelo(
      idDatosFactura: 0,
      idRestaurante: resId,
      nombreNegocio: '',
      rtn: '',
      direccion: '',
      correo: '',
      telefono: '',
      cai: '',
      rangoInicial: 0,
      rangoFinal: 0,
      fechaLimite: null,
    );
  }
}
