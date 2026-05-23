import 'package:citaria_frontend/data/models/categoria.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
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
  });

  final int id;
  final String nombre;
  final String categoria;
  final String duracion;
  final String precio;
  final bool activo;
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

  DtoServicioCatalogoAdmin _crearDtoServicio(Servicio servicio) {
    return DtoServicioCatalogoAdmin(
      id: servicio.id ?? 0,
      nombre: servicio.nombre,
      categoria: _textoConFallback(servicio.nombreCategoria, 'Sin categoría'),
      duracion: _formatearDuracion(servicio.duracionMinutos),
      precio: _formatoPrecio.format(servicio.precio),
      activo: servicio.activo ?? true,
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
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }
}
