import 'package:citaria_frontend/data/models/categoria.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/models/servicio_skill.dart';
import 'package:citaria_frontend/data/models/skill.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_base.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class DtoServicioCatalogoAdmin {
  const DtoServicioCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracion,
    required this.precio,
    required this.activo,
    this.imagenUrl,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String duracion;
  final String precio;
  final bool activo;
  final String? imagenUrl;
}

@immutable
class DtoCategoriaCatalogoAdmin {
  const DtoCategoriaCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.activo,
  });

  final int id;
  final String nombre;
  final bool activo;
}

@immutable
class DtoSkillCatalogoAdmin {
  const DtoSkillCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.activo,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final bool activo;
}

@immutable
class DtoDetalleServicioCatalogoAdmin {
  const DtoDetalleServicioCatalogoAdmin({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracionMinutos,
    required this.categoriaId,
    required this.activo,
    required this.skillIds,
    this.imagenUrl,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionMinutos;
  final int? categoriaId;
  final bool activo;
  final Set<int> skillIds;
  final String? imagenUrl;
}

class ViewModelAdminCatalogo extends ViewModelAdminBase {
  ViewModelAdminCatalogo({
    required RepoCatalogo repoCatalogo,
    required super.autenticacion,
  }) : _repoCatalogo = repoCatalogo;

  final RepoCatalogo _repoCatalogo;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );

  List<Servicio> _servicios = const <Servicio>[];
  List<Categoria> _categorias = const <Categoria>[];
  List<Skill> _skills = const <Skill>[];
  DtoDetalleServicioCatalogoAdmin? _detalleServicio;
  DtoCategoriaCatalogoAdmin? _detalleCategoria;
  DtoSkillCatalogoAdmin? _detalleSkill;

  DtoDetalleServicioCatalogoAdmin? get detalleServicio => _detalleServicio;
  DtoCategoriaCatalogoAdmin? get detalleCategoria => _detalleCategoria;
  DtoSkillCatalogoAdmin? get detalleSkill => _detalleSkill;

  List<DtoServicioCatalogoAdmin> get servicios => _servicios
      .where((servicio) => servicio.id != null)
      .map(_crearDtoServicio)
      .toList(growable: false);

  List<DtoCategoriaCatalogoAdmin> get categorias => _categorias
      .where((categoria) => categoria.id != null)
      .map(_crearDtoCategoria)
      .toList(growable: false);

  List<DtoSkillCatalogoAdmin> get skills => _skills
      .where((skill) => skill.id != null)
      .map(_crearDtoSkill)
      .toList(growable: false);

  Future<void> cargarCatalogo() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Servicio> servicios = await _repoCatalogo.listarServicios(
        token,
      );
      final List<Categoria> categorias = await _repoCatalogo.listarCategorias(
        token,
      );
      final List<Skill> skills = await _repoCatalogo.listarSkills(token);
      _servicios = List<Servicio>.from(servicios)..sort(_compararServicios);
      _categorias = List<Categoria>.from(categorias)..sort(_compararCategorias);
      _skills = List<Skill>.from(skills)..sort(_compararSkills);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<void> refrescar() {
    return cargarCatalogo();
  }

  Future<void> cargarFormularioNuevoServicio() async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final List<Categoria> categorias = await _repoCatalogo.listarCategorias(
        token,
      );
      final List<Skill> skills = await _repoCatalogo.listarSkills(token);
      _categorias = List<Categoria>.from(categorias)..sort(_compararCategorias);
      _skills = List<Skill>.from(skills)..sort(_compararSkills);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<Servicio?> crearServicio({
    required String nombre,
    required String descripcion,
    required String precio,
    required String duracion,
    required int? categoriaId,
    required Set<int> skillIds,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Servicio creado = await _repoCatalogo.crearServicio(
        Servicio(
          categoriaId: categoriaId,
          nombre: nombre.trim(),
          descripcion: _valorOpcional(descripcion),
          precio: _parsearPrecio(precio),
          duracionMinutos: _parsearEntero(duracion),
          activo: true,
        ),
        token,
      );
      final int? servicioId = creado.id;
      if (servicioId == null) {
        return creado;
      }
      for (final int skillId in skillIds) {
        await _repoCatalogo.asignarSkillServicio(servicioId, skillId, token);
      }
      return creado;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<Categoria?> crearCategoria({required String nombre}) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      return _repoCatalogo.crearCategoria(
        Categoria(nombre: nombre.trim(), activo: true),
        token,
      );
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<Skill?> crearSkill({
    required String nombre,
    required String descripcion,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      return _repoCatalogo.crearSkill(
        Skill(
          nombre: nombre.trim(),
          descripcion: _valorOpcional(descripcion),
          activo: true,
        ),
        token,
      );
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarDetalleCategoria(int id) async {
    _detalleCategoria = null;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Categoria categoria = await _repoCatalogo.obtenerCategoriaPorId(
        id,
        token,
      );
      _detalleCategoria = _crearDtoCategoria(categoria);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<Categoria?> actualizarCategoria({
    required int id,
    required String nombre,
    required bool activo,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Categoria actualizada = await _repoCatalogo.actualizarCategoria(
        id,
        Categoria(nombre: nombre.trim(), activo: activo),
        token,
      );
      _detalleCategoria = _crearDtoCategoria(actualizada);
      notifyListeners();
      return actualizada;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> desactivarCategoria(int id) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoCatalogo.desactivarCategoria(id, token);
      _detalleCategoria = null;
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarDetalleSkill(int id) async {
    _detalleSkill = null;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Skill skill = await _repoCatalogo.obtenerSkillPorId(id, token);
      _detalleSkill = _crearDtoSkill(skill);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<Skill?> actualizarSkill({
    required int id,
    required String nombre,
    required String descripcion,
    required bool activo,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Skill actualizada = await _repoCatalogo.actualizarSkill(
        id,
        Skill(
          nombre: nombre.trim(),
          descripcion: _valorOpcional(descripcion),
          activo: activo,
        ),
        token,
      );
      _detalleSkill = _crearDtoSkill(actualizada);
      notifyListeners();
      return actualizada;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> desactivarSkill(int id) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoCatalogo.desactivarSkill(id, token);
      _detalleSkill = null;
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  Future<void> cargarDetalleServicio(int id) async {
    _detalleServicio = null;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Servicio servicio = await _repoCatalogo.obtenerServicioPorId(
        id,
        token,
      );
      final List<ServicioSkill> skillsServicio = await _repoCatalogo
          .obtenerSkillsServicio(id, token);
      final List<Categoria> categorias = await _repoCatalogo.listarCategorias(
        token,
      );
      final List<Skill> skills = await _repoCatalogo.listarSkills(token);
      _categorias = List<Categoria>.from(categorias)..sort(_compararCategorias);
      _skills = List<Skill>.from(skills)..sort(_compararSkills);
      _detalleServicio = _crearDetalleServicio(servicio, skillsServicio);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<Servicio?> actualizarServicio({
    required int id,
    required String nombre,
    required String descripcion,
    required String precio,
    required String duracion,
    required int? categoriaId,
    required bool activo,
    required Set<int> skillIds,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Servicio actualizado = await _repoCatalogo.actualizarServicio(
        id,
        Servicio(
          categoriaId: categoriaId,
          nombre: nombre.trim(),
          descripcion: _valorOpcional(descripcion),
          precio: _parsearPrecio(precio),
          duracionMinutos: _parsearEntero(duracion),
          activo: activo,
        ),
        token,
      );
      await _sincronizarSkillsServicio(id, skillIds, token);
      await cargarDetalleServicio(id);
      return actualizado;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> desactivarServicio(int id) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoCatalogo.desactivarServicio(id, token);
      _detalleServicio = null;
      notifyListeners();
      return true;
    } catch (e) {
      registrarError(e);
      return false;
    } finally {
      finalizarCarga();
    }
  }

  DtoServicioCatalogoAdmin _crearDtoServicio(Servicio servicio) {
    return DtoServicioCatalogoAdmin(
      id: servicio.id ?? 0,
      nombre: servicio.nombre,
      categoria: _textoConFallback(servicio.nombreCategoria, 'Sin categoría'),
      duracion: _formatearDuracion(servicio.duracionMinutos),
      precio: _formatoPrecio.format(servicio.precio),
      activo: servicio.activo ?? true,
      imagenUrl: _textoOpcional(servicio.imagenUrl),
    );
  }

  DtoCategoriaCatalogoAdmin _crearDtoCategoria(Categoria categoria) {
    return DtoCategoriaCatalogoAdmin(
      id: categoria.id ?? 0,
      nombre: categoria.nombre,
      activo: categoria.activo ?? true,
    );
  }

  DtoSkillCatalogoAdmin _crearDtoSkill(Skill skill) {
    return DtoSkillCatalogoAdmin(
      id: skill.id ?? 0,
      nombre: skill.nombre,
      descripcion: _textoConFallback(skill.descripcion, 'Sin descripción'),
      activo: skill.activo ?? true,
    );
  }

  DtoDetalleServicioCatalogoAdmin _crearDetalleServicio(
    Servicio servicio,
    List<ServicioSkill> skillsServicio,
  ) {
    final Set<int> skillIds = skillsServicio
        .map((skill) => skill.skillId)
        .whereType<int>()
        .toSet();
    return DtoDetalleServicioCatalogoAdmin(
      id: servicio.id ?? 0,
      nombre: servicio.nombre,
      descripcion: _textoOpcional(servicio.descripcion) ?? '',
      precio: servicio.precio,
      duracionMinutos: servicio.duracionMinutos,
      categoriaId: servicio.categoriaId,
      activo: servicio.activo ?? true,
      imagenUrl: _textoOpcional(servicio.imagenUrl),
      skillIds: skillIds,
    );
  }

  Future<void> _sincronizarSkillsServicio(
    int servicioId,
    Set<int> skillIdsDeseadas,
    String token,
  ) async {
    final List<ServicioSkill> actuales = await _repoCatalogo
        .obtenerSkillsServicio(servicioId, token);
    final Set<int> actualesIds = actuales
        .map((skill) => skill.skillId)
        .whereType<int>()
        .toSet();

    for (final int skillId in actualesIds.difference(skillIdsDeseadas)) {
      await _repoCatalogo.eliminarSkillServicio(servicioId, skillId, token);
    }
    for (final int skillId in skillIdsDeseadas.difference(actualesIds)) {
      await _repoCatalogo.asignarSkillServicio(servicioId, skillId, token);
    }
  }

  int _compararServicios(Servicio a, Servicio b) {
    return a.nombre.compareTo(b.nombre);
  }

  int _compararCategorias(Categoria a, Categoria b) {
    return a.nombre.compareTo(b.nombre);
  }

  int _compararSkills(Skill a, Skill b) {
    return a.nombre.compareTo(b.nombre);
  }

  String _formatearDuracion(int minutos) {
    if (minutos < 60) {
      return '$minutos min';
    }
    final int horas = minutos ~/ 60;
    final int resto = minutos % 60;
    if (resto == 0) {
      return horas == 1 ? '1 h' : '$horas h';
    }
    return '$horas h $resto min';
  }

  String _textoConFallback(String? texto, String fallback) {
    return _textoOpcional(texto) ?? fallback;
  }

  String? _textoOpcional(String? texto) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }

  String? _valorOpcional(String valor) {
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }

  double _parsearPrecio(String valor) {
    return double.parse(valor.trim().replaceAll(',', '.'));
  }

  int _parsearEntero(String valor) {
    return int.parse(valor.trim());
  }
}
