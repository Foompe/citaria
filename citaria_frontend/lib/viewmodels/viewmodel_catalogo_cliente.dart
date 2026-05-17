import 'package:citaria_frontend/data/models/categoria.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/models/servicio_skill.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

@immutable
class DtoCategoriaCliente {
  const DtoCategoriaCliente({
    required this.id,
    required this.nombre,
    required this.activa,
  });

  final int? id;
  final String nombre;
  final bool activa;
}

@immutable
class DtoServicioCliente {
  const DtoServicioCliente({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.duracionTexto,
    required this.precioTexto,
    required this.imagenUrl,
    required this.seleccionado,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String duracionTexto;
  final String precioTexto;
  final String? imagenUrl;
  final bool seleccionado;
}

@immutable
class DtoDetalleServicioCliente {
  const DtoDetalleServicioCliente({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.duracionTexto,
    required this.precioTexto,
    required this.imagenUrl,
    required this.skills,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String duracionTexto;
  final String precioTexto;
  final String? imagenUrl;
  final List<String> skills;
}

class ViewModelCatalogoCliente extends ChangeNotifier {
  ViewModelCatalogoCliente({
    required RepoCatalogo repoCatalogo,
    required ViewModelAutenticacion autenticacion,
  }) : _repoCatalogo = repoCatalogo,
       _autenticacion = autenticacion;

  final RepoCatalogo _repoCatalogo;
  final ViewModelAutenticacion _autenticacion;
  final NumberFormat _formatoPrecio = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
  );

  bool _cargando = false;
  String? _error;
  List<Servicio> _servicios = const <Servicio>[];
  List<Categoria> _categorias = const <Categoria>[];
  int? _categoriaSeleccionadaId;
  String _busqueda = '';
  DtoDetalleServicioCliente? _detalle;

  bool get cargando => _cargando;
  String? get error => _error;
  int? get categoriaSeleccionadaId => _categoriaSeleccionadaId;
  String get busqueda => _busqueda;
  DtoDetalleServicioCliente? get detalle => _detalle;

  List<DtoCategoriaCliente> get categorias {
    return <DtoCategoriaCliente>[
      DtoCategoriaCliente(
        id: null,
        nombre: 'Todos',
        activa: _categoriaSeleccionadaId == null,
      ),
      ..._categorias.map(
        (categoria) => DtoCategoriaCliente(
          id: categoria.id,
          nombre: categoria.nombre,
          activa: categoria.id == _categoriaSeleccionadaId,
        ),
      ),
    ];
  }

  List<DtoServicioCliente> get servicios {
    final String filtro = _busqueda.trim().toLowerCase();
    return _servicios
        .where((servicio) {
          final bool categoriaOk =
              _categoriaSeleccionadaId == null ||
              servicio.categoriaId == _categoriaSeleccionadaId;
          final bool busquedaOk =
              filtro.isEmpty ||
              servicio.nombre.toLowerCase().contains(filtro) ||
              (servicio.descripcion ?? '').toLowerCase().contains(filtro);
          return categoriaOk && busquedaOk;
        })
        .map(_crearDtoServicio)
        .toList(growable: false);
  }

  List<DtoServicioCliente> get serviciosDestacados {
    return servicios.take(3).toList(growable: false);
  }

  Future<void> cargarCatalogo() async {
    _setCargando(true);
    _limpiarError();

    try {
      final String token = await _leerTokenObligatorio();
      final List<Categoria> categorias = await _repoCatalogo.listarCategorias(
        token,
      );
      final List<Servicio> servicios = await _repoCatalogo.listarServicios(
        token,
      );
      _categorias = categorias
          .where((categoria) => categoria.activo != false)
          .toList(growable: false);
      _servicios = servicios
          .where((servicio) => servicio.activo != false && servicio.id != null)
          .toList(growable: false);
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  void seleccionarCategoria(int? categoriaId) {
    _categoriaSeleccionadaId = categoriaId;
    notifyListeners();
  }

  void buscar(String valor) {
    _busqueda = valor;
    notifyListeners();
  }

  Future<void> cargarDetalleServicio(int id) async {
    _setCargando(true);
    _limpiarError();

    try {
      final String token = await _leerTokenObligatorio();
      final Servicio servicio = await _repoCatalogo.obtenerServicioPorId(
        id,
        token,
      );
      final List<ServicioSkill> skills = await _repoCatalogo
          .obtenerSkillsServicio(id, token);
      _detalle = _crearDtoDetalle(servicio, skills);
      notifyListeners();
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  DtoServicioCliente? obtenerServicio(int id) {
    for (final Servicio servicio in _servicios) {
      if (servicio.id == id) {
        return _crearDtoServicio(servicio);
      }
    }
    return null;
  }

  DtoServicioCliente _crearDtoServicio(Servicio servicio) {
    return DtoServicioCliente(
      id: servicio.id ?? 0,
      nombre: servicio.nombre,
      descripcion: _textoConFallback(servicio.descripcion, 'Sin descripción'),
      categoria: _textoConFallback(servicio.nombreCategoria, 'Sin categoría'),
      duracionTexto: '${servicio.duracionMinutos} min',
      precioTexto: _formatoPrecio.format(servicio.precio),
      imagenUrl: servicio.imagenUrl,
      seleccionado: false,
    );
  }

  DtoDetalleServicioCliente _crearDtoDetalle(
    Servicio servicio,
    List<ServicioSkill> skills,
  ) {
    return DtoDetalleServicioCliente(
      id: servicio.id ?? 0,
      nombre: servicio.nombre,
      categoria: _textoConFallback(servicio.nombreCategoria, 'Sin categoría'),
      descripcion: _textoConFallback(servicio.descripcion, 'Sin descripción'),
      duracionTexto: '${servicio.duracionMinutos} min',
      precioTexto: _formatoPrecio.format(servicio.precio),
      imagenUrl: servicio.imagenUrl,
      skills: skills
          .map((skill) => skill.nombreSkill)
          .whereType<String>()
          .where((skill) => skill.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  String _textoConFallback(String? texto, String fallback) {
    final String? limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? fallback : limpio;
  }

  Future<String> _leerTokenObligatorio() async {
    final String? token = await _autenticacion.leerToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesión no disponible.');
    }
    return token;
  }

  String _mensajeError(Object error) {
    final String mensaje = error.toString();
    return mensaje.startsWith('Exception: ')
        ? mensaje.replaceFirst('Exception: ', '')
        : mensaje;
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }

  void _setError(String mensaje) {
    _error = mensaje;
    notifyListeners();
  }

  void _limpiarError() {
    _error = null;
  }
}
