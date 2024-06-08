abstract class Reporte {
  Reporte({
    required this.cantMenu,
    required this.cantPedidosDiarios,
    required this.ingresosDiarios,
    required this.clientes,
    required this.totalEfectivo,
    required this.totalTarjeta,
    required this.totalTransferencia,
    required this.cantEfectivo,
    required this.cantTarjeta,
    required this.cantTransferencia,
  });
  final int cantMenu;
  final int cantPedidosDiarios;
  final double ingresosDiarios;
  final int clientes;
  final double totalEfectivo;
  final double totalTarjeta;
  final double totalTransferencia;
  final int cantEfectivo;
  final int cantTarjeta;
  final int cantTransferencia;
}
