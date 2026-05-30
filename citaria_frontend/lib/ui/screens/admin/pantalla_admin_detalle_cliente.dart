import 'package:citaria_frontend/data/enums/estado_reserva.dart' as datos;
import 'package:citaria_frontend/data/repositories/repo_clientes.dart';
import 'package:citaria_frontend/ui/widgets/avatar_editable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:citaria_frontend/data/repositories/repo_reservas.dart';
import 'package:citaria_frontend/ui/navigation/gestor_navegacion.dart';
import 'package:citaria_frontend/ui/theme/extension_espaciado.dart';
import 'package:citaria_frontend/ui/widgets/cabecera_titulo_grande.dart';
import 'package:citaria_frontend/ui/widgets/chip_estado.dart' as chip;
import 'package:citaria_frontend/ui/widgets/divisor_citaria.dart';
import 'package:citaria_frontend/ui/widgets/estado_centrado.dart';
import 'package:citaria_frontend/ui/widgets/tarjeta_reserva_admin.dart';
import 'package:citaria_frontend/viewmodels/admin/viewmodel_admin_clientes.dart';
import 'package:citaria_frontend/viewmodels/viewmodel_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// P25 — Ficha de cliente en el área admin.
///
/// Ruta: /admin/clientes/:id  — arguments: {'id': String}
class PantallaAdminDetalleCliente extends StatefulWidget {
  const PantallaAdminDetalleCliente({super.key});

  @override
  State<PantallaAdminDetalleCliente> createState() =>
      _PantallaAdminDetalleClienteState();
}

class _PantallaAdminDetalleClienteState
    extends State<PantallaAdminDetalleCliente>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ViewModelAdminClientes _viewModel;
  int? _clienteId;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = ViewModelAdminClientes(
      repoClientes: context.read<RepoClientes>(),
      repoReservas: context.read<RepoReservas>(),
      autenticacion: context.read<ViewModelAutenticacion>(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) {
      return;
    }
    _inicializado = true;
    final int? id = _leerIdCliente(context);
    _clienteId = id;
    if (id != null) {
      _viewModel.cargarDetalleCliente(id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, true);
      },
      child: ChangeNotifierProvider<ViewModelAdminClientes>.value(
        value: _viewModel,
        child: _ContenidoDetalleCliente(
          tabController: _tabController,
          clienteId: _clienteId,
        ),
      ),
    );
  }

  int? _leerIdCliente(BuildContext context) {
    final Object? argumentos = ModalRoute.of(context)?.settings.arguments;
    if (argumentos is Map<String, dynamic>) {
      final Object? id = argumentos['id'];
      if (id is int) {
        return id;
      }
      if (id is String) {
        return int.tryParse(id);
      }
    }
    return null;
  }
}

class _ContenidoDetalleCliente extends StatelessWidget {
  const _ContenidoDetalleCliente({
    required this.tabController,
    required this.clienteId,
  });

  final TabController tabController;
  final int? clienteId;

  @override
  Widget build(BuildContext context) {
    final vmClientes = context.watch<ViewModelAdminClientes>();
    final detalle = vmClientes.detalle;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            const CabeceraTituloGrande(titulo: 'Cliente'),
          ],
          body: SafeArea(
            top: false,
            child: _CuerpoDetalleCliente(
              clienteId: clienteId,
              detalle: detalle,
              reservas: vmClientes.reservasCliente,
              vmClientes: vmClientes,
              tabController: tabController,
              espaciado: espaciado,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
        ),
      ),
    );
  }
}

class _CuerpoDetalleCliente extends StatelessWidget {
  const _CuerpoDetalleCliente({
    required this.clienteId,
    required this.detalle,
    required this.reservas,
    required this.vmClientes,
    required this.tabController,
    required this.espaciado,
    required this.colorScheme,
    required this.textTheme,
  });

  final int? clienteId;
  final DtoDetalleClienteAdmin? detalle;
  final List<DtoReservaClienteAdmin> reservas;
  final ViewModelAdminClientes vmClientes;
  final TabController tabController;
  final EspaciadoCitaria espaciado;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  Future<void> _editarFoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (imagen == null || !context.mounted) return;

    final List<int> bytes = await imagen.readAsBytes();
    if (!context.mounted) return;
    final bool ok = await vmClientes.subirFoto(
      id: clienteId!,
      bytes: bytes,
      nombreFichero: imagen.name,
    );

    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vmClientes.error ?? 'No se pudo subir la foto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (clienteId == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado el cliente.',
        accionTexto: 'Volver',
        onAccion: () => Navigator.maybePop(context),
      );
    }

    if (vmClientes.cargando && detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = vmClientes.error;
    if (error != null && detalle == null) {
      return EstadoCentrado(
        mensaje: error,
        accionTexto: 'Reintentar',
        onAccion: () => vmClientes.cargarDetalleCliente(clienteId!),
      );
    }

    final DtoDetalleClienteAdmin? cliente = detalle;
    if (cliente == null) {
      return EstadoCentrado(
        mensaje: 'No se ha encontrado el cliente.',
        accionTexto: 'Reintentar',
        onAccion: () => vmClientes.cargarDetalleCliente(clienteId!),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(espaciado.padX, 24, espaciado.padX, 16),
          child: Column(
            children: [
              AvatarEditable(
                texto: cliente.nombreCompleto,
                fotoUrl: cliente.fotoUrl,
                cargando: vmClientes.cargando,
                onEditar: () => _editarFoto(context),
              ),
              const SizedBox(height: 12),
              Text(
                cliente.nombreCompleto,
                style: textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                cliente.email,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Datos'),
            Tab(text: 'Reservas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _TabDatos(cliente: cliente),
              _TabReservas(
                clienteId: clienteId!,
                reservas: reservas,
                clienteNombre: cliente.nombreCompleto,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _CampoAdmin { nombre, apellidos, dni, telefono, notas }

class _TabDatos extends StatefulWidget {
  const _TabDatos({required this.cliente});

  final DtoDetalleClienteAdmin cliente;

  @override
  State<_TabDatos> createState() => _TabDatosState();
}

class _TabDatosState extends State<_TabDatos> {
  _CampoAdmin? _campoEnEdicion;
  final TextEditingController _controlador = TextEditingController();

  static String _raw(String dtoValue, String fallback) =>
      dtoValue == fallback ? '' : dtoValue;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _editarCampo(_CampoAdmin campo, String valorOriginal) {
    setState(() {
      _campoEnEdicion = campo;
      _controlador.text = valorOriginal;
      _controlador.selection = TextSelection.fromPosition(
        TextPosition(offset: _controlador.text.length),
      );
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _campoEnEdicion = null;
      _controlador.clear();
    });
  }

  String? _validarCampo(_CampoAdmin campo, String valor) {
    switch (campo) {
      case _CampoAdmin.nombre:
        if (valor.isEmpty) return 'El nombre es obligatorio';
        if (valor.length < 2) return 'El nombre debe tener al menos 2 caracteres';
        if (valor.length > 50) return 'El nombre no puede superar los 50 caracteres';
      case _CampoAdmin.apellidos:
        if (valor.length > 100) return 'Los apellidos no pueden superar los 100 caracteres';
      case _CampoAdmin.dni:
        if (valor.length > 9) return 'El documento no puede superar los 9 caracteres';
      case _CampoAdmin.telefono:
        if (valor.isNotEmpty && valor.length < 9) return 'El teléfono debe tener al menos 9 caracteres';
        if (valor.length > 15) return 'El teléfono no puede superar los 15 caracteres';
      case _CampoAdmin.notas:
        if (valor.length > 500) return 'Las notas no pueden superar los 500 caracteres';
    }
    return null;
  }

  Future<void> _guardarCampo(
    BuildContext context,
    ViewModelAdminClientes vmClientes,
  ) async {
    final _CampoAdmin? campo = _campoEnEdicion;
    if (campo == null) return;

    final String valor = _controlador.text.trim();
    final String? errorValidacion = _validarCampo(campo, valor);
    if (errorValidacion != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorValidacion)),
      );
      return;
    }

    final c = widget.cliente;
    final bool ok = await vmClientes.actualizarCliente(
      id: c.id,
      nombre: campo == _CampoAdmin.nombre ? valor : c.nombre,
      apellidos: campo == _CampoAdmin.apellidos
          ? valor
          : _raw(c.apellidos, 'Sin apellidos'),
      dni: campo == _CampoAdmin.dni ? valor : _raw(c.dni, 'Sin DNI'),
      telefono: campo == _CampoAdmin.telefono
          ? valor
          : _raw(c.telefono, 'Sin teléfono'),
      notas: campo == _CampoAdmin.notas ? valor : (c.notas ?? ''),
    );

    if (!context.mounted) return;
    if (ok) {
      _cancelarEdicion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vmClientes.error ?? 'No se pudo guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmClientes = context.watch<ViewModelAdminClientes>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final espaciado = Theme.of(context).extension<EspaciadoCitaria>()!;
    final bool cargando = vmClientes.cargando;
    final c = widget.cliente;

    return ListView(
      padding: EdgeInsets.fromLTRB(espaciado.padX, 16, espaciado.padX, 24),
      children: [
        Text(
          'DATOS',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: espaciado.radioCard),
          child: Column(
            children: [
              _FilaDatoAdmin(
                icono: Icons.person_outline,
                label: 'Nombre',
                valor: c.nombre,
                campo: _CampoAdmin.nombre,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () => _editarCampo(_CampoAdmin.nombre, c.nombre),
                onGuardar: () => _guardarCampo(context, vmClientes),
                onCancelar: _cancelarEdicion,
              ),
              const DivisorCitaria(),
              _FilaDatoAdmin(
                icono: Icons.group_outlined,
                label: 'Apellidos',
                valor: c.apellidos,
                campo: _CampoAdmin.apellidos,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () => _editarCampo(
                  _CampoAdmin.apellidos,
                  _raw(c.apellidos, 'Sin apellidos'),
                ),
                onGuardar: () => _guardarCampo(context, vmClientes),
                onCancelar: _cancelarEdicion,
              ),
              const DivisorCitaria(),
              _FilaDatoAdmin(
                icono: Icons.badge_outlined,
                label: 'DNI',
                valor: c.dni,
                campo: _CampoAdmin.dni,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () =>
                    _editarCampo(_CampoAdmin.dni, _raw(c.dni, 'Sin DNI')),
                onGuardar: () => _guardarCampo(context, vmClientes),
                onCancelar: _cancelarEdicion,
              ),
              const DivisorCitaria(),
              _FilaDatoAdmin(
                icono: Icons.email_outlined,
                label: 'Email',
                valor: c.email,
              ),
              const DivisorCitaria(),
              _FilaDatoAdmin(
                icono: Icons.phone_outlined,
                label: 'Teléfono',
                valor: c.telefono,
                campo: _CampoAdmin.telefono,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () => _editarCampo(
                  _CampoAdmin.telefono,
                  _raw(c.telefono, 'Sin teléfono'),
                ),
                onGuardar: () => _guardarCampo(context, vmClientes),
                onCancelar: _cancelarEdicion,
              ),
              const DivisorCitaria(),
              _FilaDatoAdmin(
                icono: Icons.notes_outlined,
                label: 'Notas',
                valor: c.notas ?? 'No indicado',
                campo: _CampoAdmin.notas,
                campoEnEdicion: _campoEnEdicion,
                controller: _controlador,
                guardando: cargando,
                onEditar: () =>
                    _editarCampo(_CampoAdmin.notas, c.notas ?? ''),
                onGuardar: () => _guardarCampo(context, vmClientes),
                onCancelar: _cancelarEdicion,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          onPressed: cargando
              ? null
              : () => _darDeBaja(context, vmClientes, c.id),
          child: const Text('Dar de baja'),
        ),
      ],
    );
  }

  Future<void> _darDeBaja(
    BuildContext context,
    ViewModelAdminClientes vmClientes,
    int id,
  ) async {
    final bool ok = await vmClientes.darDeBajaCliente(id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vmClientes.error ?? 'No se pudo dar de baja.')),
    );
  }
}

// ── Fila de dato editable (patrón perfil cliente) ─────────────────────────────

class _FilaDatoAdmin extends StatelessWidget {
  const _FilaDatoAdmin({
    required this.icono,
    required this.label,
    required this.valor,
    this.campo,
    this.campoEnEdicion,
    this.controller,
    this.guardando = false,
    this.onEditar,
    this.onGuardar,
    this.onCancelar,
  });

  final IconData icono;
  final String label;
  final String valor;
  final _CampoAdmin? campo;
  final _CampoAdmin? campoEnEdicion;
  final TextEditingController? controller;
  final bool guardando;
  final VoidCallback? onEditar;
  final VoidCallback? onGuardar;
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool editable = campo != null;
    final bool editando = editable && campoEnEdicion == campo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icono, color: colorScheme.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                if (editando)
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    enabled: !guardando,
                    onFieldSubmitted: (_) => onGuardar?.call(),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(valor, style: textTheme.bodyLarge),
              ],
            ),
          ),
          if (editando) ...[
            IconButton(
              tooltip: 'Cancelar',
              icon: Icon(Icons.close, color: colorScheme.outline, size: 20),
              onPressed: guardando ? null : onCancelar,
            ),
            IconButton(
              tooltip: 'Guardar $label',
              icon: guardando
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Icon(Icons.check, color: colorScheme.primary, size: 20),
              onPressed: guardando ? null : onGuardar,
            ),
          ] else if (editable)
            Semantics(
              label: 'Editar $label',
              child: IconButton(
                tooltip: 'Editar $label',
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.outline,
                  size: 18,
                ),
                onPressed: onEditar,
              ),
            ),
        ],
      ),
    );
  }
}

class _TabReservas extends StatelessWidget {
  const _TabReservas({
    required this.clienteId,
    required this.reservas,
    required this.clienteNombre,
  });

  final int clienteId;
  final List<DtoReservaClienteAdmin> reservas;
  final String clienteNombre;

  @override
  Widget build(BuildContext context) {
    if (reservas.isEmpty) {
      return Center(
        child: Text(
          'Sin reservas',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        final DtoReservaClienteAdmin reserva = reservas[index];
        return TarjetaReservaAdmin(
          estado: _estadoVisual(reserva.estado),
          cliente: clienteNombre,
          servicio: reserva.servicio,
          empleado: reserva.empleado,
          hora: reserva.hora,
          precio: reserva.precio,
          onTap: () async {
            final cambiado =
                await GestorNavegacion.irAAdminDetalleReserva(context, reserva.id);
            if (cambiado == true && context.mounted) {
              context.read<ViewModelAdminClientes>().cargarDetalleCliente(
                clienteId,
              );
            }
          },
        );
      },
    );
  }
}

chip.EstadoReserva _estadoVisual(datos.EstadoReserva estado) {
  switch (estado) {
    case datos.EstadoReserva.pendiente:
      return chip.EstadoReserva.pendiente;
    case datos.EstadoReserva.confirmada:
      return chip.EstadoReserva.confirmada;
    case datos.EstadoReserva.cancelada:
      return chip.EstadoReserva.cancelada;
    case datos.EstadoReserva.completada:
      return chip.EstadoReserva.completada;
  }
}
