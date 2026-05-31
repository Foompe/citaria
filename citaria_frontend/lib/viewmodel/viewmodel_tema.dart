import 'package:citaria_frontend/data/models/configuracion_visual.dart';
import 'package:citaria_frontend/data/repositories/repo_organizaciones.dart';
import 'package:citaria_frontend/dto/dto_tema_empresa.dart';
import 'package:citaria_frontend/ui/theme/tema_citaria.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mantiene el tema visual (colores) de la empresa activa que aplica la app.
class ViewModelTema extends ChangeNotifier {
  ViewModelTema({
    required RepoOrganizaciones repoOrganizaciones,
    required SharedPreferences preferencias,
  }) : _repoOrganizaciones = repoOrganizaciones,
       _preferencias = preferencias;

  static const String _claveLogoUrl = 'citaria.tema.logoUrl';
  static const String _claveColorPrimario = 'citaria.tema.colorPrimario';
  static const String _claveColorSecundario = 'citaria.tema.colorSecundario';
  static const String _claveTipografia = 'citaria.tema.tipografia';
  static const String _claveVersion = 'citaria.tema.version';

  final RepoOrganizaciones _repoOrganizaciones;
  final SharedPreferences _preferencias;

  bool _cargando = false;
  String? _error;
  DtoTemaEmpresa? _datos;
  ThemeData _themeData = temaCitaria;

  bool get cargando => _cargando;
  String? get error => _error;
  DtoTemaEmpresa? get datos => _datos;
  ThemeData get themeData => _themeData;
  int? get versionActual => _preferencias.getInt(_claveVersion);

  Future<void> inicializar() async {
    _setCargando(true);
    _limpiarError();

    try {
      final DtoTemaEmpresa? temaGuardado = _leerTemaGuardado();
      if (temaGuardado != null) {
        _aplicarTema(temaGuardado);
      }
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cargarTemaEmpresa(int organizacionId) async {
    _setCargando(true);
    _limpiarError();
    await restaurarFallback();

    try {
      final ConfiguracionVisual configuracion = await _repoOrganizaciones
          .obtenerConfiguracion(organizacionId);
      await _guardarYAplicar(configuracion);
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> comprobarActualizacion(int organizacionId) async {
    _setCargando(true);
    _limpiarError();

    try {
      final ConfiguracionVisual configuracion = await _repoOrganizaciones
          .obtenerConfiguracion(organizacionId);
      final int? versionRemota = configuracion.version;
      final int? versionLocal = _preferencias.getInt(_claveVersion);

      if (versionLocal == null ||
          versionRemota == null ||
          versionRemota > versionLocal) {
        await _guardarYAplicar(configuracion);
        return;
      }

      final DtoTemaEmpresa? temaGuardado = _datos ?? _leerTemaGuardado();
      if (temaGuardado != null) {
        _aplicarTema(temaGuardado);
      }
    } catch (e) {
      _setError(_mensajeError(e));
    } finally {
      _setCargando(false);
    }
  }

  Future<void> restaurarFallback() async {
    _datos = null;
    _themeData = temaCitaria;
    await _guardarStringOpcional(_claveLogoUrl, null);
    await _guardarStringOpcional(_claveColorPrimario, null);
    await _guardarStringOpcional(_claveColorSecundario, null);
    await _guardarStringOpcional(_claveTipografia, null);
    await _preferencias.remove(_claveVersion);
    notifyListeners();
  }

  Future<void> _guardarYAplicar(ConfiguracionVisual configuracion) async {
    await _guardarConfiguracion(configuracion);
    final DtoTemaEmpresa tema = _crearDtoTema(configuracion);
    _aplicarTema(tema);
  }

  Future<void> _guardarConfiguracion(ConfiguracionVisual configuracion) async {
    await _guardarStringOpcional(_claveLogoUrl, configuracion.logoUrl);
    await _guardarStringOpcional(
      _claveColorPrimario,
      configuracion.colorPrimario,
    );
    await _guardarStringOpcional(
      _claveColorSecundario,
      configuracion.colorSecundario,
    );
    await _guardarStringOpcional(_claveTipografia, configuracion.tipografia);

    final int? version = configuracion.version;
    if (version == null) {
      await _preferencias.remove(_claveVersion);
    } else {
      await _preferencias.setInt(_claveVersion, version);
    }
  }

  Future<void> _guardarStringOpcional(String clave, String? valor) async {
    if (valor == null || valor.isEmpty) {
      await _preferencias.remove(clave);
      return;
    }
    await _preferencias.setString(clave, valor);
  }

  DtoTemaEmpresa? _leerTemaGuardado() {
    final String? colorPrimarioTexto = _preferencias.getString(
      _claveColorPrimario,
    );
    final String? colorSecundarioTexto = _preferencias.getString(
      _claveColorSecundario,
    );

    if (colorPrimarioTexto == null && colorSecundarioTexto == null) {
      return null;
    }

    return DtoTemaEmpresa(
      logoUrl: _preferencias.getString(_claveLogoUrl),
      colorPrimario:
          _parseColor(colorPrimarioTexto) ?? temaCitaria.colorScheme.primary,
      colorSecundario:
          _parseColor(colorSecundarioTexto) ??
          temaCitaria.colorScheme.secondary,
      tipografia: _preferencias.getString(_claveTipografia),
    );
  }

  DtoTemaEmpresa _crearDtoTema(ConfiguracionVisual configuracion) {
    return DtoTemaEmpresa(
      logoUrl: configuracion.logoUrl,
      colorPrimario:
          _parseColor(configuracion.colorPrimario) ??
          temaCitaria.colorScheme.primary,
      colorSecundario:
          _parseColor(configuracion.colorSecundario) ??
          temaCitaria.colorScheme.secondary,
      tipografia: configuracion.tipografia,
    );
  }

  void _aplicarTema(DtoTemaEmpresa tema) {
    _datos = tema;
    _themeData = _construirThemeData(tema);
    notifyListeners();
  }

  ThemeData _construirThemeData(DtoTemaEmpresa tema) {
    final ColorScheme colorScheme = temaCitaria.colorScheme.copyWith(
      primary: tema.colorPrimario,
      onPrimary: Colors.white,
      primaryContainer: tema.colorPrimario.withValues(alpha: 0.12),
      onPrimaryContainer: tema.colorPrimario,
      secondary: tema.colorSecundario,
    );
    final TextTheme textTheme = _aplicarTipografia(
      tema.tipografia,
      temaCitaria.textTheme,
    );

    final OutlineInputBorder focusedBase =
        temaCitaria.inputDecorationTheme.focusedBorder! as OutlineInputBorder;

    return temaCitaria.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      inputDecorationTheme: temaCitaria.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: focusedBase.borderRadius,
          borderSide: BorderSide(color: tema.colorPrimario, width: 1.5),
        ),
      ),
      appBarTheme: temaCitaria.appBarTheme.copyWith(
        titleTextStyle: textTheme.displaySmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: temaCitaria.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(tema.colorPrimario),
          foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: temaCitaria.outlinedButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      bottomNavigationBarTheme: temaCitaria.bottomNavigationBarTheme.copyWith(
        selectedItemColor: tema.colorPrimario,
      ),
      chipTheme: temaCitaria.chipTheme.copyWith(
        labelStyle: textTheme.bodySmall,
      ),
    );
  }

  TextTheme _aplicarTipografia(String? tipografia, TextTheme fallback) {
    final String? nombre = tipografia?.trim();
    if (nombre == null || nombre.isEmpty) {
      return fallback;
    }

    try {
      return GoogleFonts.getTextTheme(nombre, fallback);
    } catch (_) {
      return fallback;
    }
  }

  Color? _parseColor(String? valor) {
    final String? normalizado = valor?.trim();
    if (normalizado == null || normalizado.isEmpty) {
      return null;
    }

    final String hex = normalizado.startsWith('#')
        ? normalizado.substring(1)
        : normalizado.replaceFirst('0x', '').replaceFirst('0X', '');

    final String conAlpha = hex.length == 6 ? 'FF$hex' : hex;
    if (conAlpha.length != 8) {
      return null;
    }

    final int? color = int.tryParse(conAlpha, radix: 16);
    return color == null ? null : Color(color);
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
