package com.citaria.dto;

import com.citaria.model.EstadoReserva;
import jakarta.validation.constraints.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * DTO para la transferencia de datos de una reserva.
 */
public class ReservaDTO {

    private Integer id;
    private Integer organizacionId;
    private Integer clienteId;
    private String nombreCliente;
    private EstadoReserva estado;

    @NotNull(message = "La fecha es obligatoria")
    private LocalDate fecha;

    @NotNull(message = "La hora de inicio es obligatoria")
    private LocalTime horaInicio;

    private Integer empleadoId;

    @NotEmpty(message = "Debe seleccionar al menos un servicio")
    @Size(max = 5, message = "No se pueden seleccionar más de 5 servicios por reserva")
    private List<Integer> servicioIds;

    @Size(max = 500, message = "Las observaciones no pueden superar los 500 caracteres")
    private String notas;

    @Size(max = 300, message = "El motivo no puede superar los 300 caracteres")
    private String motivo;
    private List<ReservaServicioDTO> lineas;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getOrganizacionId() { return organizacionId; }
    public void setOrganizacionId(Integer organizacionId) { this.organizacionId = organizacionId; }

    public Integer getClienteId() { return clienteId; }
    public void setClienteId(Integer clienteId) { this.clienteId = clienteId; }

    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String nombreCliente) { this.nombreCliente = nombreCliente; }

    public EstadoReserva getEstado() { return estado; }
    public void setEstado(EstadoReserva estado) { this.estado = estado; }

    public LocalDate getFecha() { return fecha; }
    public void setFecha(LocalDate fecha) { this.fecha = fecha; }

    public LocalTime getHoraInicio() { return horaInicio; }
    public void setHoraInicio(LocalTime horaInicio) { this.horaInicio = horaInicio; }

    public Integer getEmpleadoId() { return empleadoId; }
    public void setEmpleadoId(Integer empleadoId) { this.empleadoId = empleadoId; }

    public List<Integer> getServicioIds() { return servicioIds; }
    public void setServicioIds(List<Integer> servicioIds) { this.servicioIds = servicioIds; }

    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }

    public String getMotivo() { return motivo; }
    public void setMotivo(String motivo) { this.motivo = motivo; }

    public List<ReservaServicioDTO> getLineas() { return lineas; }
    public void setLineas(List<ReservaServicioDTO> lineas) { this.lineas = lineas; }
}