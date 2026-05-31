/// Formatea una hora `"HH:mm:ss"` o `"HH:mm"` a `"HH:mm"`: descarta los
/// segundos y rellena horas/minutos a dos dígitos. Si el valor no tiene
/// formato de hora (sin `:`), lo devuelve tal cual.
String formatearHoraHm(String hora) {
  final List<String> partes = hora.split(':');
  if (partes.length < 2) return hora;
  return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
}
