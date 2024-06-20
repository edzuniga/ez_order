import 'package:intl/intl.dart';

class NumberToWordsEs {
  static const List<String> unidades = [
    '',
    'uno',
    'dos',
    'tres',
    'cuatro',
    'cinco',
    'seis',
    'siete',
    'ocho',
    'nueve'
  ];

  static const List<String> decenas = [
    '',
    'diez',
    'veinte',
    'treinta',
    'cuarenta',
    'cincuenta',
    'sesenta',
    'setenta',
    'ochenta',
    'noventa'
  ];

  static const List<String> teens = [
    'once',
    'doce',
    'trece',
    'catorce',
    'quince',
    'dieciséis',
    'diecisiete',
    'dieciocho',
    'diecinueve'
  ];

  static const List<String> centenas = [
    '',
    'cien',
    'doscientos',
    'trescientos',
    'cuatrocientos',
    'quinientos',
    'seiscientos',
    'setecientos',
    'ochocientos',
    'novecientos'
  ];

  static String convertNumberToWords(double number) {
    final formatter = NumberFormat("#.00");
    String formattedNumber = formatter.format(number);
    List<String> parts = formattedNumber.split('.');

    int integerPart = int.parse(parts[0]);
    int decimalPart = int.parse(parts[1]);

    return "${convertIntegerToWords(integerPart)} lempiras con ${convertIntegerToWords(decimalPart)} centavos";
  }

  static String convertIntegerToWords(int number) {
    if (number == 0) return 'cero';

    if (number < 10) return unidades[number];
    if (number >= 10 && number < 20) {
      return number == 10 ? 'diez' : teens[number - 11];
    }
    if (number >= 20 && number < 100) {
      return decenas[number ~/ 10] +
          (number % 10 == 0 ? '' : ' y ${unidades[number % 10]}');
    }
    if (number >= 100 && number < 1000) {
      return centenas[number ~/ 100] +
          (number % 100 == 0 ? '' : ' ${convertIntegerToWords(number % 100)}');
    }
    if (number >= 1000 && number < 1000000) {
      int thousands = number ~/ 1000;
      int remainder = number % 1000;
      return '${convertIntegerToWords(thousands)} mil ${remainder == 0 ? '' : convertIntegerToWords(remainder)}';
    }
    // Extend this function for larger numbers if needed

    return '';
  }
}
