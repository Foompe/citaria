import 'package:citaria_frontend/data/models/categoria.dart';
import 'package:citaria_frontend/data/models/servicio.dart';
import 'package:citaria_frontend/data/models/servicio_habilidad.dart';
import 'package:citaria_frontend/data/models/habilidad.dart';
import 'package:citaria_frontend/data/repositories/repo_catalogo.dart';
import 'package:citaria_frontend/dto/admin/dto_categoria_catalogo_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_detalle_servicio_catalogo_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_habilidad_catalogo_admin.dart';
import 'package:citaria_frontend/dto/admin/dto_servicio_catalogo_admin.dart';
import 'package:citaria_frontend/viewmodel/admin/viewmodel_admin_base.dart';
import 'package:intl/intl.dart';

/// Gestiona el catálogo en admin: servicios, categorías y habilidades.
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
  List<Habilidad> _habilidades = const <Habilidad>[];
  DtoDetalleServicioCatalogoAdmin? _detalleServicio;
  DtoCategoriaCatalogoAdmin? _detalleCategoria;
  DtoHabilidadCatalogoAdmin? _detalleHabilidad;

  DtoDetalleServicioCatalogoAdmin? get detalleServicio => _detalleServicio;
  DtoCategoriaCatalogoAdmin? get detalleCategoria => _detalleCategoria;
  DtoHabilidadCatalogoAdmin? get detalleHabilidad => _detalleHabilidad;

  List<DtoServicioCatalogoAdmin> get servicios => _servicios
      .where((servicio) => servicio.id != null)
      .map(_crearDtoServicio)
      .toList(growable: false);

  List<DtoCategoriaCatalogoAdmin> get categorias => _categorias
      .where((categoria) => categoria.id != null)
      .map(_crearDtoCategoria)
      .toList(growable: false);

  List<DtoHabilidadCatalogoAdmin> get habilidades => _habilidades
      .where((habilidad) => habilidad.id != null)
      .map(_crearDtoHabilidad)
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
      final List<Habilidad> habilidades = await _repoCatalogo.listarHabilidades(token);
      _servicios = List<Servicio>.from(servicios)..sort(_compararServicios);
      _categorias = List<Categoria>.from(categorias)..sort(_compararCategorias);
      _habilidades = List<Habilidad>.from(habilidades)..sort(_compararHabilidades);
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
      final List<Habilidad> habilidades = await _repoCatalogo.listarHabilidades(token);
      _categorias = List<Categoria>.from(categorias)..sort(_compararCategorias);
      _habilidades = List<Habilidad>.from(habilidades)..sort(_compararHabilidades);
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
    required Set<int> habilidadIds,
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
      for (final int habilidadId in habilidadIds) {
        await _repoCatalogo.asignarHabilidadServicio(servicioId, habilidadId, token);
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

  Future<Habilidad?> crearHabilidad({
    required String nombre,
    required String descripcion,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      return _repoCatalogo.crearHabilidad(
        Habilidad(
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

  Future<void> cargarDetalleHabilidad(int id) async {
    _detalleHabilidad = null;
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Habilidad habilidad = await _repoCatalogo.obtenerHabilidadPorId(id, token);
      _detalleHabilidad = _crearDtoHabilidad(habilidad);
      notifyListeners();
    } catch (e) {
      registrarError(e);
    } finally {
      finalizarCarga();
    }
  }

  Future<Habilidad?> actualizarHabilidad({
    required int id,
    required String nombre,
    required String descripcion,
    required bool activo,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      final Habilidad actualizada = await _repoCatalogo.actualizarHabilidad(
        id,
        Habilidad(
          nombre: nombre.trim(),
          descripcion: _valorOpcional(descripcion),
          activo: activo,
        ),
        token,
      );
      _detalleHabilidad = _crearDtoHabilidad(actualizada);
      notifyListeners();
      return actualizada;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> desactivarHabilidad(int id) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoCatalogo.desactivarHabilidad(id, token);
      _detalleHabilidad = null;
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
      final List<ServicioHabilidad> habilidadesServicio = await _repoCatalogo
          .obtenerHabilidadesServicio(id, token);
      final List<Categoria> categorias = await _repoCatalogo.listarCategorias(
        token,
      );
      final List<Habilidad> habilidades = await _repoCatalogo.listarHabilidades(token);
      _categorias = List<Categoria>.from(categorias)..sort(_compararCategorias);
      _habilidades = List<Habilidad>.from(habilidades)..sort(_compararHabilidades);
      _detalleServicio = _crearDetalleServicio(servicio, habilidadesServicio);
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
    required Set<int> habilidadIds,
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
      await _sincronizarHabilidadesServicio(id, habilidadIds, token);
      await cargarDetalleServicio(id);
      return actualizado;
    } catch (e) {
      registrarError(e);
      return null;
    } finally {
      finalizarCarga();
    }
  }

  Future<bool> subirImagenServicio({
    required int id,
    required List<int> bytes,
    required String nombreFichero,
  }) async {
    iniciarCarga();

    try {
      final String token = leerTokenObligatorio();
      await _repoCatalogo.subirImagenServicio(id, bytes, nombreFichero, token);
      await cargarDetalleServicio(id);
      return true;
    } catch (e) {
      registrarError(e);
      return false;
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

  DtoHabilidadCatalogoAdmin _crearDtoHabilidad(Habilidad habilidad) {
    return DtoHabilidadCatalogoAdmin(
      id: habilidad.id ?? 0,
      nombre: habilidad.nombre,
      descripcion: _textoConFallback(habilidad.descripcion, 'Sin descripción'),
      activo: habilidad.activo ?? true,
    );
  }

  DtoDetalleServicioCatalogoAdmin _crearDetalleServicio(
    Servicio servicio,
    List<ServicioHabilidad> habilidadesServicio,
  ) {
    final Set<int> habilidadIds = habilidadesServicio
        .map((habilidad) => habilidad.habilidadId)
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
      habilidadIds: habilidadIds,
    );
  }

  Future<void> _sincronizarHabilidadesServicio(
    int servicioId,
    Set<int> habilidadIdsDeseadas,
    String token,
  ) async {
    final List<ServicioHabilidad> actuales = await _repoCatalogo
        .obtenerHabilidadesServicio(servicioId, token);
    final Set<int> actualesIds = actuales
        .map((habilidad) => habilidad.habilidadId)
        .whereType<int>()
        .toSet();

    for (final int habilidadId in actualesIds.difference(habilidadIdsDeseadas)) {
      await _repoCatalogo.eliminarHabilidadServicio(servicioId, habilidadId, token);
    }
    for (final int habilidadId in habilidadIdsDeseadas.difference(actualesIds)) {
      await _repoCatalogo.asignarHabilidadServicio(servicioId, habilidadId, token);
    }
  }

  int _compararServicios(Servicio a, Servicio b) {
    return a.nombre.compareTo(b.nombre);
  }

  int _compararCategorias(Categoria a, Categoria b) {
    return a.nombre.compareTo(b.nombre);
  }

  int _compararHabilidades(Habilidad a, Habilidad b) {
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
