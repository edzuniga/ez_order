abstract class DatosFactura {
  DatosFactura({
    required this.idDatosFactura,
    required this.idRestaurante,
    required this.nombreNegocio,
    required this.rtn,
    required this.direccion,
    required this.correo,
    required this.telefono,
    required this.cai,
    required this.rangoInicial,
    required this.rangoFinal,
    required this.fechaLimite,
  });

  final int idDatosFactura;
  final int idRestaurante;
  final String nombreNegocio;
  final String rtn;
  final String direccion;
  final String correo;
  final String telefono;
  final String cai;
  final int rangoInicial;
  final int rangoFinal;
  final DateTime fechaLimite;
}
