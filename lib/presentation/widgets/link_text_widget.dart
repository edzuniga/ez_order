import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LinkText extends StatefulWidget {
  const LinkText({
    required this.textito,
    this.colorcito = Colors.blue,
    this.tamano = 14,
    this.subrayado = false,
    super.key,
  });

  final String textito;
  final Color colorcito;
  final double tamano;
  final bool subrayado;

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() {
        isHover = true;
      }),
      onExit: (_) => setState(() {
        isHover = false;
      }),
      child: Text(
        widget.textito,
        style: GoogleFonts.poppins(
            color: widget.colorcito,
            fontSize: widget.tamano,
            fontWeight: FontWeight.w600,
            decoration: isHover && widget.subrayado
                ? TextDecoration.underline
                : TextDecoration.none),
      ),
    );
  }
}
