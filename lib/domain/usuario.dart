abstract class Usuario {
  Usuario({
    this.uuidUsuario,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.idRestaurante,
  });

  final String? uuidUsuario;
  final String email;
  final String nombre;
  final int rol;
  final int idRestaurante;
}
