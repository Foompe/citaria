import 'package:citaria_frontend/data/models/empleado.dart';
import 'package:citaria_frontend/data/models/empleado_skill.dart';
import 'package:citaria_frontend/data/models/horario_empleado.dart';
import 'package:citaria_frontend/data/models/horario_organizacion.dart';
import 'package:citaria_frontend/data/models/skill.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/data/repositories/repo_empleados.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';

@immutable
class DtoEmpleadoAdmin {
  const DtoEmpleadoAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.iniciales,
    required this.activo,
    required this.estado,
    required this.resumen,
    required this.fotoUrl,
  });

  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String iniciales;
  final bool activo;
  final String estado;
  final String resumen;
  final String? fotoUrl;
}

@immutable
class DtoDetalleEmpleadoAdmin {
  const DtoDetalleEmpleadoAdmin({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.iniciales,
    required this.activo,
    required this.estado,
    required this.fotoUrl,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String iniciales;
  final bool activo;
  final String estado;
  final String? fotoUrl;
}

@immutable
class DtoHorarioEmpleadoAdmin {
  const DtoHorarioEmpleadoAdmin({
    required this.id,
    required this.diaSemana,
    required this.dia,
    required this.activo,
    required this.horario,
    required this.horaInicio,
    required this.horaFin,
  });

  final int? id;
  final int diaSemana;
  final String dia;
  final bool activo;
  final String horario;
  final String horaInicio;
  final String horaFin;
}

@immutable
class DtoSkillEmpleadoAdmin {
  const DtoSkillEmpleadoAdmin({required this.id, required this.nombre});

  final int id;
  final String nombre;
}

@immutable
class DtoSkillDisponibleEmpleadoAdmin {
  const DtoSkillDisponibleEmpleadoAdmin({
    required this.id,
    required this.nombre,
  });

  final int id;
  final String nombre;
}

@immutable
class DtoHorarioNuevoEmpleadoAdmin {
  const DtoHorarioNuevoEmpleadoAdmin({
    required this.diaSemana,
    required this.dia,
    required this.activo,
    required this.horaInicio,
    required this.horaFin,
  });

  final int diaSemana;
  final String dia;
  final bool activo;
  final String horaInicio;
  final String horaFin;

  String get horario =>
      '${_formatearHoraEstatica(horaInicio)} - '
      '${_formatearHoraEstatica(horaFin)}';

  DtoHorarioNuevoEmpleadoAdmin copyWith({bool? activo}) {
    return DtoHorarioNuevoEmpleadoAdmin(
      diaSemana: diaSemana,
      dia: dia,
      activo: activo ?? this.activo,
      horaInicio: horaInicio,
      horaFin: horaFin,
    );
  }
}

class ViewModelAdminEmpleados extends ViewModelAdminBase {
  ViewModelAdminEmpleados({
    required RepoEmpleados repoEmpleados,
    required RepoCatalogo repoCatalogo,
    required RepoOrganizaciones repoOrganizaciones,
    required super.autenticacion,
  }) : _repoEmpleados = repoEmpleados,
       _repoCatalogo = repoCatalogo,
       _repoOrganizaciones = repoOrganizaciones;

  final RepoEmpleados _repoEmpleados;
  final RepoCatalogo _repoCatalogo;
  final RepoOrganizaciones _repoOrganizaciones;

  List<Empleado> _empleados = const <Empleado>[];
  DtoDetalleEmpleadoAdmin? _detalle;
  List<DtoHorarioEmpleadoAdmin> _horarios = const <DtoHorarioEmpleadoAdmin>[];
  List<DtoSkillEmpleadoAdmin> _skills = const <DtoSkillEmpleadoAdmin>[];
  List<DtoSkillDisponibleEmpleadoAdmin> _skillsDisponibles =
      const <DtoSkillDisponibleEmpleadoAdmin>[];
  List<DtoHorarioNuevoEmpleadoAdmin> _horariosNuevo =
      const <DtoHorarioNuevoEmpleadoAdmin>[];
  String _busqueda = '';

  String get busqueda => _busqueda;
  DtoDetalleEmpleadoAdmin? get detalle => _detalle;
  List<DtoHorarioEmpleadoAdmin> get horarios => _horarios;
  List<DtoSkillEmpleadoAdmin> get skills => _skills;
  List<DtoSkillDisponibleEmpleadoAdmin> get skillsDisponibles =>
      _skillsDisponibles;
  List<DtoHorarioNuevoEmpleadoAdmin> get horariosNuevo => _horariosNuevo;

  List<DtoEmpleadoAdmin> get empleados {
    final String filtro = _normalizar(_busqueda);
    return _empleados
        .where((empleado) => empleado.id != null)
        .where((empleado) => _coincideConBusqueda(empleado, filtro))
        .map(_crearDto)
        .toList(growable: false);
  }

  Future<void> cargarEmpleados() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Empleado> empleados = await _repoEmpleados.listarTodos(token);
      _empleados =
          empleados
              .where((empleado) => empleado.anonimizadoAt == null)
              .toList(growable: false)
            ..sort(_compararEmpleados);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarEmpleados();
  }

  Future<void> cargarDetalleEmpleado(int id) async {
    _detalle = null;
    _horarios = const <DtoHorarioEmpleadoAdmin>[];
    _skills = const <DtoSkillEmpleadoAdmin>[];
    _skillsDisponibles = const <DtoSkillDisponibleEmpleadoAdmin>[];
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Empleado empleado = await _repoEmpleados.obtenerPorId(id, token);
      final List<HorarioEmpleado> horarios = await _repoEmpleados
          .obtenerHorarios(id, token);
      final List<EmpleadoSkill> skills = await _repoEmpleados.obtenerSkills(
        id,
        token,
      );
      final List<Skill> skillsDisponibles = await _repoCatalogo.listarSkills(
        token,
      );
      _detalle = _crearDetalle(empleado);
      _horarios = _crearHorarios(horarios);
      _skills = _crearSkills(skills);
      _skillsDisponibles = _crearSkillsDisponibles(skillsDisponibles);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarSkillsDisponibles() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Skill> skills = await _repoCatalogo.listarSkills(token);
      _skillsDisponibles =
          skills
              .where((skill) => skill.id != null)
              .where((skill) => skill.activo ?? true)
              .map(
                (skill) => DtoSkillDisponibleEmpleadoAdmin(
                  id: skill.id ?? 0,
                  nombre: skill.nombre,
                ),
              )
              .toList(growable: false)
            ..sort((a, b) => a.nombre.compareTo(b.nombre));
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarFormularioNuevoEmpleado() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final int organizacionId = leerOrganizacionIdObligatoria();
      final List<Skill> skills = await _repoCatalogo.listarSkills(token);
      final List<HorarioOrganizacion> horarios = await _repoOrganizaciones
          .obtenerHorarios(organizacionId, token);
      _skillsDisponibles = _crearSkillsDisponibles(skills);
      _horariosNuevo = _crearHorariosNuevo(horarios);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  void alternarHorarioNuevo(int index, bool activo) {
    if (index < 0 || index >= _horariosNuevo.length) {
      return;
    }
    _horariosNuevo = List<DtoHorarioNuevoEmpleadoAdmin>.from(_horariosNuevo)
      ..[index] = _horariosNuevo[index].copyWith(activo: activo);
    notifyListeners();
  }

  Future<Empleado?> crearEmpleado({
    required String nombre,
    required String apellidos,
    required String email,
    required String telefono,
    required Set<int> skillIds,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Empleado creado = await _repoEmpleados.crear(
        Empleado(
          nombre: nombre.trim(),
          apellidos: apellidos.trim(),
          email: _valorOpcional(email),
          telefono: _valorOpcional(telefono),
          activo: true,
        ),
        token,
      );
      final int? empleadoId = creado.id;
      if (empleadoId == null) {
        return creado;
      }

      await _crearHorariosIniciales(empleadoId, token);
      await _asignarSkillsIniciales(empleadoId, skillIds, token);
      return creado;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  void buscar(String valor) {
    if (_busqueda == valor) {
      return;
    }
    _busqueda = valor;
    notifyListeners();
  }

  Future<bool> actualizarEmpleado({
    required int id,
    required String nombre,
    required String apellidos,
    required String email,
    required String telefono,
  }) async {
    try {
      final String token = leerTokenObligatorio();
      final Empleado actualizado = await _repoEmpleados.actualizar(
        id,
        Empleado(
          nombre: nombre.trim(),
          apellidos: apellidos.trim(),
          email: _valorOpcional(email),
          telefono: _valorOpcional(telefono),
        ),
        token,
      );
      _detalle = _crearDetalle(actualizado);
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    }
  }

  Future<bool> subirFoto({
    required int id,
    required List<int> bytes,
    required String nombreFichero,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoEmpleados.subirFoto(id, bytes, nombreFichero, token);
      await cargarDetalleEmpleado(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> cambiarEstadoEmpleado(int id, {required bool activo}) async {
    try {
      final String token = leerTokenObligatorio();
      final Empleado empleado = await _repoEmpleados.obtenerPorId(id, token);
      final Empleado actualizado = await _repoEmpleados.actualizar(
        id,
        Empleado(
          nombre: empleado.nombre,
          apellidos: empleado.apellidos,
          email: empleado.email,
          telefono: empleado.telefono,
          activo: activo,
        ),
        token,
      );
      _detalle = _crearDetalle(actualizado);
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    }
  }

  Future<bool> guardarHorario({
    required int empleadoId,
    required DtoHorarioEmpleadoAdmin horario,
    required bool activo,
    required String horaInicio,
    required String horaFin,
  }) async {
    try {
      final String token = leerTokenObligatorio();
      final HorarioEmpleado datos = HorarioEmpleado(
        diaSemana: horario.diaSemana,
        horaInicio: horaInicio,
        horaFin: horaFin,
        activo: activo,
      );
      final HorarioEmpleado resultado;
      final int? horarioId = horario.id;
      if (horarioId != null) {
        resultado = await _repoEmpleados.actualizarHorario(
          empleadoId,
          horarioId,
          datos,
          token,
        );
      } else {
        resultado = await _repoEmpleados.crearHorario(
          empleadoId,
          datos,
          token,
        );
      }
      final int idx = _horarios.indexWhere(
        (h) => h.diaSemana == horario.diaSemana,
      );
      if (idx >= 0) {
        final List<DtoHorarioEmpleadoAdmin> actualizado = List.from(_horarios);
        actualizado[idx] = DtoHorarioEmpleadoAdmin(
          id: resultado.id,
          diaSemana: resultado.diaSemana,
          dia: horario.dia,
          activo: resultado.activo,
          horario:
              '${_formatearHora(resultado.horaInicio)} - '
              '${_formatearHora(resultado.horaFin)}',
          horaInicio: resultado.horaInicio,
          horaFin: resultado.horaFin,
        );
        _horarios = actualizado;
      }
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    }
  }

  Future<bool> asignarSkillDetalle({
    required int empleadoId,
    required int skillId,
  }) async {
    try {
      final String token = leerTokenObligatorio();
      final EmpleadoSkill asignada = await _repoEmpleados.asignarSkill(
        empleadoId,
        skillId,
        token,
      );
      final int? sid = asignada.skillId;
      final String? nombre = asignada.nombreSkill;
      if (sid != null && nombre != null) {
        _skills = [
          ..._skills,
          DtoSkillEmpleadoAdmin(id: sid, nombre: nombre),
        ]..sort((a, b) => a.nombre.compareTo(b.nombre));
        notifyListeners();
      }
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    }
  }

  Future<bool> eliminarSkillDetalle({
    required int empleadoId,
    required int skillId,
  }) async {
    try {
      final String token = leerTokenObligatorio();
      await _repoEmpleados.eliminarSkill(empleadoId, skillId, token);
      _skills = _skills
          .where((s) => s.id != skillId)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    }
  }

  DtoEmpleadoAdmin _crearDto(Empleado empleado) {
    final String nombreCompleto = _crearNombreCompleto(empleado);
    final bool activo = empleado.activo ?? true;
    return DtoEmpleadoAdmin(
      id: empleado.id ?? 0,
      nombreCompleto: nombreCompleto,
      email: _textoConFallback(empleado.email, 'Sin email'),
      telefono: _textoConFallback(empleado.telefono, 'Sin teléfono'),
      iniciales: _crearIniciales(nombreCompleto),
      activo: activo,
      estado: activo ? 'Activo' : 'Inactivo',
      resumen: _crearResumen(empleado),
      fotoUrl: _textoOpcional(empleado.fotoUrl),
    );
  }

  DtoDetalleEmpleadoAdmin _crearDetalle(Empleado empleado) {
    final String nombreCompleto = _crearNombreCompleto(empleado);
    final bool activo = empleado.activo ?? true;
    return DtoDetalleEmpleadoAdmin(
      id: empleado.id ?? 0,
      nombre: _textoConFallback(empleado.nombre, 'Sin nombre'),
      apellidos: _textoConFallback(empleado.apellidos, 'Sin apellidos'),
      nombreCompleto: nombreCompleto,
      email: _textoConFallback(empleado.email, 'Sin email'),
      telefono: _textoConFallback(empleado.telefono, 'Sin teléfono'),
      iniciales: _crearIniciales(nombreCompleto),
      activo: activo,
      estado: activo ? 'Activo' : 'Inactivo',
      fotoUrl: _textoOpcional(empleado.fotoUrl),
    );
  }

  List<DtoHorarioEmpleadoAdmin> _crearHorarios(List<HorarioEmpleado> horarios) {
    final Map<int, HorarioEmpleado> porDia = <int, HorarioEmpleado>{};
    for (final HorarioEmpleado horario in horarios) {
      final int? indice = _indiceDiaSemana(horario.diaSemana);
      if (indice != null) {
        porDia[indice] = horario;
      }
    }

    return List<DtoHorarioEmpleadoAdmin>.generate(_diasSemana.length, (index) {
      final HorarioEmpleado? horario = porDia[index];
      if (horario == null) {
        return DtoHorarioEmpleadoAdmin(
          id: null,
          diaSemana: index + 1,
          dia: _diasSemana[index],
          activo: false,
          horario: 'Cerrado',
          horaInicio: '09:00',
          horaFin: '18:00',
        );
      }
      return DtoHorarioEmpleadoAdmin(
        id: horario.id,
        diaSemana: horario.diaSemana,
        dia: _diasSemana[index],
        activo: horario.activo,
        horario:
            '${_formatearHora(horario.horaInicio)} - '
            '${_formatearHora(horario.horaFin)}',
        horaInicio: horario.horaInicio,
        horaFin: horario.horaFin,
      );
    }, growable: false);
  }

  List<DtoSkillEmpleadoAdmin> _crearSkills(List<EmpleadoSkill> skills) {
    return skills
        .where((skill) => skill.skillId != null && skill.nombreSkill != null)
        .map(
          (skill) =>
              DtoSkillEmpleadoAdmin(id: skill.skillId!, nombre: skill.nombreSkill!),
        )
        .toList(growable: false)
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  List<DtoSkillDisponibleEmpleadoAdmin> _crearSkillsDisponibles(
    List<Skill> skills,
  ) {
    return skills
        .where((skill) => skill.id != null)
        .where((skill) => skill.activo ?? true)
        .map(
          (skill) => DtoSkillDisponibleEmpleadoAdmin(
            id: skill.id ?? 0,
            nombre: skill.nombre,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  List<DtoHorarioNuevoEmpleadoAdmin> _crearHorariosNuevo(
    List<HorarioOrganizacion> horarios,
  ) {
    final Map<int, HorarioOrganizacion> porDia = <int, HorarioOrganizacion>{};
    for (final HorarioOrganizacion horario in horarios) {
      final int? indice = _indiceDiaSemana(horario.diaSemana);
      if (indice != null) {
        porDia[indice] = horario;
      }
    }

    return List<DtoHorarioNuevoEmpleadoAdmin>.generate(_diasSemana.length, (
      index,
    ) {
      final HorarioOrganizacion? horario = porDia[index];
      return DtoHorarioNuevoEmpleadoAdmin(
        diaSemana: index + 1,
        dia: _diasSemana[index],
        activo: horario?.activo ?? false,
        horaInicio: horario?.horaApertura ?? '00:00',
        horaFin: horario?.horaCierre ?? '00:00',
      );
    }, growable: false);
  }

  Future<void> _crearHorariosIniciales(int empleadoId, String token) async {
    for (final DtoHorarioNuevoEmpleadoAdmin horario in _horariosNuevo) {
      await _repoEmpleados.crearHorario(
        empleadoId,
        HorarioEmpleado(
          diaSemana: horario.diaSemana,
          horaInicio: horario.horaInicio,
          horaFin: horario.horaFin,
          activo: horario.activo,
        ),
        token,
      );
    }
  }

  Future<void> _asignarSkillsIniciales(
    int empleadoId,
    Set<int> skillIds,
    String token,
  ) async {
    for (final int skillId in skillIds) {
      await _repoEmpleados.asignarSkill(empleadoId, skillId, token);
    }
  }

  bool _coincideConBusqueda(Empleado empleado, String filtro) {
    if (filtro.isEmpty) {
      return true;
    }
    final List<String?> campos = <String?>[
      empleado.nombre,
      empleado.apellidos,
      empleado.email,
      empleado.telefono,
    ];
    return campos.any((campo) => _normalizar(campo ?? '').contains(filtro));
  }

  int _compararEmpleados(Empleado a, Empleado b) {
    return _crearNombreCompleto(a).compareTo(_crearNombreCompleto(b));
  }

  String _crearNombreCompleto(Empleado empleado) {
    final String nombre = empleado.nombre.trim();
    final String? apellidos = _textoOpcional(empleado.apellidos);
    if (apellidos == null) {
      return nombre.isEmpty ? 'Empleado sin nombre' : nombre;
    }
    return '$nombre $apellidos';
  }

  String _crearResumen(Empleado empleado) {
    final String email = _textoConFallback(empleado.email, 'Sin email');
    final String telefono = _textoConFallback(
      empleado.telefono,
      'Sin teléfono',
    );
    return '$email · $telefono';
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
    return _formatearHoraEstatica(hora);
  }

  String _crearIniciales(String texto) {
    final List<String> partes = texto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList(growable: false);
    if (partes.isEmpty) {
      return 'E';
    }
    final String primera = partes.first.substring(0, 1).toUpperCase();
    if (partes.length == 1) {
      return primera;
    }
    return '$primera${partes.last.substring(0, 1).toUpperCase()}';
  }

  String _textoConFallback(String? texto, String fallback) {
    return _textoOpcional(texto) ?? fallback;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }

  String _normalizar(String texto) {
    return texto.trim().toLowerCase();
  }

  String? _valorOpcional(String valor) {
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
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

String _formatearHoraEstatica(String hora) {
  final List<String> partes = hora.split(':');
  if (partes.length >= 2) {
    return '${partes[0]}:${partes[1]}';
  }
  return hora;
}
