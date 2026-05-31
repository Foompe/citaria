import 'package:flutter_test/flutter_test.dart';

import 'package:citaria_frontend/ui/utils/validadores.dart';

/// Tests de los validadores de formulario. Son métodos estáticos puros que
/// devuelven `String?` (null = válido), así que no hacen falta dobles: se
/// comprueba null en los casos válidos y no-null en los inválidos, sin
/// acoplarse al texto exacto del mensaje.
void main() {
  group('nombrePersonaValidador', () {
    test('vacío obligatorio es inválido; opcional es válido', () {
      expect(Validadores.nombrePersonaValidador(''), isNotNull);
      expect(Validadores.nombrePersonaValidador('   '), isNotNull); // trim
      expect(Validadores.nombrePersonaValidador(null), isNotNull);
      expect(Validadores.nombrePersonaValidador('', obligatorio: false), isNull);
      expect(Validadores.nombrePersonaValidador(null, obligatorio: false), isNull);
    });

    test('respeta los límites de longitud', () {
      expect(Validadores.nombrePersonaValidador('A'), isNotNull); // < min (2)
      expect(Validadores.nombrePersonaValidador('A' * 51), isNotNull); // > max (50)
      expect(Validadores.nombrePersonaValidador('Ana'), isNull);
    });
  });

  group('telefonoValidador', () {
    test('vacío es válido por defecto (opcional) y exigible si obligatorio', () {
      expect(Validadores.telefonoValidador(''), isNull);
      expect(Validadores.telefonoValidador(null), isNull);
      expect(Validadores.telefonoValidador('', obligatorio: true), isNotNull);
    });

    test('respeta los límites de longitud', () {
      expect(Validadores.telefonoValidador('12345678'), isNotNull); // < min (9)
      expect(Validadores.telefonoValidador('1' * 16), isNotNull); // > max (15)
      expect(Validadores.telefonoValidador('612345678'), isNull);
    });
  });

  group('emailValidador', () {
    test('vacío es válido por defecto (opcional) y exigible si obligatorio', () {
      expect(Validadores.emailValidador(''), isNull);
      expect(Validadores.emailValidador('', obligatorio: true), isNotNull);
    });

    test('comprueba el formato', () {
      expect(Validadores.emailValidador('abc'), isNotNull);
      expect(Validadores.emailValidador('a@b'), isNotNull);
      expect(Validadores.emailValidador('foo@bar.com'), isNull);
    });
  });

  group('dniValidador', () {
    test('vacío siempre es válido y respeta el máximo', () {
      expect(Validadores.dniValidador(''), isNull);
      expect(Validadores.dniValidador(null), isNull);
      expect(Validadores.dniValidador('1234567890'), isNotNull); // > max (9)
      expect(Validadores.dniValidador('12345678Z'), isNull);
    });
  });

  group('precioValidador', () {
    test('exige un número positivo y acepta coma decimal', () {
      expect(Validadores.precioValidador(null), isNotNull);
      expect(Validadores.precioValidador(''), isNotNull);
      expect(Validadores.precioValidador('abc'), isNotNull);
      expect(Validadores.precioValidador('0'), isNotNull); // <= 0
      expect(Validadores.precioValidador('-5'), isNotNull);
      expect(Validadores.precioValidador('12,50'), isNull); // coma → punto
      expect(Validadores.precioValidador('10'), isNull);
    });
  });

  group('obligatorioValidador', () {
    test('vacío o solo espacios es inválido; con contenido es válido', () {
      expect(Validadores.obligatorioValidador(''), isNotNull);
      expect(Validadores.obligatorioValidador('   '), isNotNull);
      expect(Validadores.obligatorioValidador(null), isNotNull);
      expect(Validadores.obligatorioValidador('algo'), isNull);
    });
  });
}
