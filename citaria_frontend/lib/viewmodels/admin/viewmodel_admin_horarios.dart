import 'package:citaria_frontend/data/models/cierre_organizacion.dart';
import 'package:citaria_frontend/data/models/horario_organizacion.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class DtoHorarioOrganizacionAdmin {
  const DtoHorarioOrganizacionAdmin({
    required this.id,
    required this.dia,
    required this.activo,
    required this.horario,
  });

  final int? id;
  final String dia;
  final bool activo;
  final String horario;
}

@immutable
class DtoCierreOrganizacionAdmin {
  const DtoCierreOrganizacionAdmin({
    required this.id,
    required this.fecha,
    required this.motivo,
  });

  final int id;
  final String fecha;
  final String motivo;
}

class ViewModelAdminHorarios extends ViewModelAdminBase {
  ViewModelAdminHorarios({
    required RepoOrganizaciones repoOrganizaciones,
    required super.autenticacion,
  }) : _repoOrganizaciones = repoOrganizaciones;

  final RepoOrganizaciones _repoOrganizaciones;
  final DateFormat _formatoFecha = DateFormat('d MMM yyyy', 'es_ES');

  List<HorarioOrganizacion> _horarios = const <HorarioOrganizacion>[];
  List<CierreOrganizacion> _cierres = const <CierreOrganizacion>[];

  List<DtoHorarioOrganizacionAdmin> get horarios => _crearHorarios();

  List<DtoCierreOrganizacionAdmin> get cierres => _cierres
      .where((cierre) => cierre.id != null)
      .map(_crearCierreDto)
      .toList(growable: false);

  Future<void> cargarHorarios() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final int organizacionId = leerOrganizacionIdObligatoria();
      final List<HorarioOrganizacion> horarios = await _repoOrganizaciones
          .obtenerHorarios(organizacionId, token);
      final List<CierreOrganizacion> cierres = await _repoOrganizaciones
          .obtenerCierres(organizacionId, token);
      _horarios = List<HorarioOrganizacion>.from(horarios);
      _cierres = List<CierreOrganizacion>.from(cierres)
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarHorarios();
  }

  Future<DtoCierreOrganizacionAdmin?> crearCierre({
    required DateTime fecha,
    String? motivo,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final int organizacionId = leerOrganizacionIdObligatoria();
      final CierreOrganizacion cierreCreado = await _repoOrganizaciones
          .crearCierre(
            organizacionId,
            CierreOrganizacion(fecha: fecha, motivo: motivo),
            token,
          );

      _cierres = <CierreOrganizacion>[..._cierres, cierreCreado]
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
      notifyListeners();

      return _crearCierreDto(cierreCreado);
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> eliminarCierre(int id) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final int organizacionId = leerOrganizacionIdObligatoria();
      await _repoOrganizaciones.eliminarCierre(organizacionId, id, token);
      _cierres = _cierres.where((cierre) => cierre.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  List<DtoHorarioOrganizacionAdmin> _crearHorarios() {
    final Map<int, HorarioOrganizacion> porDia = <int, HorarioOrganizacion>{};
    for (final HorarioOrganizacion horario in _horarios) {
      final int? indice = _indiceDiaSemana(horario.diaSemana);
      if (indice != null) {
        porDia[indice] = horario;
      }
    }

    return List<DtoHorarioOrganizacionAdmin>.generate(_diasSemana.length, (
      index,
    ) {
      final HorarioOrganizacion? horario = porDia[index];
      if (horario == null) {
        return DtoHorarioOrganizacionAdmin(
          id: null,
          dia: _diasSemana[index],
          activo: false,
          horario: 'Cerrado',
        );
      }
      return DtoHorarioOrganizacionAdmin(
        id: horario.id,
        dia: _diasSemana[index],
        activo: horario.activo,
        horario:
            '${_formatearHora(horario.horaApertura)} - '
            '${_formatearHora(horario.horaCierre)}',
      );
    }, growable: false);
  }

  DtoCierreOrganizacionAdmin _crearCierreDto(CierreOrganizacion cierre) {
    return DtoCierreOrganizacionAdmin(
      id: cierre.id ?? 0,
      fecha: _formatoFecha.format(cierre.fecha),
      motivo: _textoConFallback(cierre.motivo, 'Sin motivo'),
    );
  }

  int? _indiceDiaSemana(int diaSemana) {
    if (diaSemana >= 1 && diaSemana <= 7) {
      return diaSemana - 1;
    }
    if (diaSemana >= 0 && diaSemana <= 6) {
      return diaSemana;
    }
    return null;
  }

  String _formatearHora(String hora) {
    final List<String> partes = hora.split(':');
    if (partes.length >= 2) {
      return '${partes[0]}:${partes[1]}';
    }
    return hora;
  }

  String _textoConFallback(String? texto, String fallback) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }
}

const List<String> _diasSemana = <String>[
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
