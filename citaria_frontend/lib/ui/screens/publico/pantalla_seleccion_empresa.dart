import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:citaria_frontend/ui/navegacion/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/avatar_fallback_citaria.dart';
import 'package:citaria_frontend/ui/widgets/hero_logo_citaria.dart';

/// Modelo de datos temporal para la lista hardcodeada.
///
/// TODO: sustituir por entidad real del dominio cuando exista.
class _DatosEmpresa {
  const _DatosEmpresa({
    required this.nombre,
    required this.descripcion,
    this.logoAsset,
  });

  final String nombre;
  final String descripcion;
  final String? logoAsset;
}

/// P02 — Selección de empresa.
///
/// Primera pantalla real del flujo. Muestra las empresas disponibles,
/// permite escoger una y navega a login al confirmar.
class PantallaSeleccionEmpresa extends StatefulWidget {
  const PantallaSeleccionEmpresa({super.key});

  @override
  State<PantallaSeleccionEmpresa> createState() =>
      _PantallaSeleccionEmpresaState();
}

class _PantallaSeleccionEmpresaState extends State<PantallaSeleccionEmpresa> {
  // TODO: cargar de API — GET /empresas
  static const List<_DatosEmpresa> _empresas = [
    _DatosEmpresa(
      nombre: 'DetailCarWash Madrid',
      descripcion: 'Lavado y detailing premium · Alcobendas',
      logoAsset: 'assets/images/logo_citaria.png',
    ),
    _DatosEmpresa(
      nombre: 'DetailCarWash Norte',
      descripcion: 'Lavado y detailing premium · Las Rozas',
    ),
    _DatosEmpresa(
      nombre: 'DetailCarWash Sur',
      descripcion: 'Lavado y detailing premium · Getafe',
    ),
  ];

  int? _indiceSeleccionado;
  DateTime? _ultimoIntentoSalir;

  void _seleccionarEmpresa(int index) {
    setState(() => _indiceSeleccionado = index);
  }

  void _continuar() {
    if (_indiceSeleccionado == null) return;

    // TODO: guardar empresa seleccionada y cargar configuración visual.
    GestorNavegacion.irALogin(context);
  }

  void _manejarIntentoSalir() {
    final ahora = DateTime.now();
    final puedeSalir = _ultimoIntentoSalir != null &&
        ahora.difference(_ultimoIntentoSalir!) < const Duration(seconds: 2);

    if (puedeSalir) {
      SystemNavigator.pop();
      return;
    }

    _ultimoIntentoSalir = ahora;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pulsa atrás de nuevo para salir'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _manejarIntentoSalir();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              espaciado.padX,
              24,
              espaciado.padX,
              espaciado.safeBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Hero(
                    tag: heroLogoCitaria,
                    child: Image.asset(
                      'assets/images/logo_citaria.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Empresas', style: textTheme.displayMedium),
                const SizedBox(height: 6),
                Text(
                  'Escoge la empresa en la que deseas entrar.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: espaciado.radioCard,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1.2,
                      ),
                    ),
                    child: ListView.separated(
                      itemCount: _empresas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final empresa = _empresas[index];

                        return _TarjetaEmpresa(
                          empresa: empresa,
                          seleccionada: _indiceSeleccionado == index,
                          onTap: () => _seleccionarEmpresa(index),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _indiceSeleccionado == null ? null : _continuar,
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta seleccionable para representar una empresa disponible.
class _TarjetaEmpresa extends StatelessWidget {
  const _TarjetaEmpresa({
    required this.empresa,
    required this.seleccionada,
    required this.onTap,
  });

  final _DatosEmpresa empresa;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: espaciado.radioCard,
      child: InkWell(
        borderRadius: espaciado.radioCard,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: espaciado.radioCard,
            border: Border.all(
              color: seleccionada
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: seleccionada ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              AvatarFallbackCitaria(
                texto: empresa.nombre,
                imagenAsset: empresa.logoAsset,
                tamano: 44,
                radio: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(empresa.nombre, style: textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      empresa.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                seleccionada
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: seleccionada ? colorScheme.primary : colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
