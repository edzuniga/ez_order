import 'package:ez_order_ezr/data/datos_factura_modelo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'datos_factura_provider.g.dart';

@Riverpod(keepAlive: true)
class DatosFacturaManager extends _$DatosFacturaManager {
  @override
  DatosFacturaModelo build() {
    return DatosFacturaModelo(
      idDatosFactura: 0,
      idRestaurante: 0,
      nombreNegocio: '',
      rtn: '',
      direccion: '',
      correo: '',
      telefono: '',
      cai: '',
      rangoInicial: 0,
      rangoFinal: 0,
      fechaLimite: DateTime(
          DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
    );
  }

  void setDatosFactura(DatosFacturaModelo datos) {
    state = datos;
  }

  void resetDatosFactura() {
    state = DatosFacturaModelo(
      idDatosFactura: 0,
      idRestaurante: 0,
      nombreNegocio: '',
      rtn: '',
      direccion: '',
      correo: '',
      telefono: '',
      cai: '',
      rangoInicial: 0,
      rangoFinal: 0,
      fechaLimite: DateTime(
          DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
    );
  }
}
