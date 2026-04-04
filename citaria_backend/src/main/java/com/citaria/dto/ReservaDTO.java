package com.citaria.dto;

import com.citaria.model.EstadoReserva;
import jakarta.validation.constraints.*;
import java.time.LocalDate;

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

    private String notas;

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

    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }
}