package com.citaria.dto;

import com.citaria.model.EstadoReservaServicio;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalTime;

/**
 * DTO de una línea de detalle de una reserva.
 */
public class ReservaServicioDTO {

    private Integer id;
    private Integer reservaId;

    @NotNull(message = "El servicio es obligatorio")
    private Integer servicioId;

    private String nombreServicio;

    @NotNull(message = "El empleado es obligatorio")
    private Integer empleadoId;

    private String nombreEmpleado;

    @NotNull(message = "La hora de inicio es obligatoria")
    private LocalTime horaInicio;

    @NotNull(message = "La hora de fin es obligatoria")
    private LocalTime horaFin;

    @NotNull(message = "El precio unitario es obligatorio")
    @DecimalMin(value = "0.01", message = "El precio debe ser mayor que cero")
    @Digits(integer = 8, fraction = 2, message = "El precio no puede tener más de 8 dígitos enteros y 2 decimales")
    private BigDecimal precioUnitario;

    @Min(value = 1, message = "La cantidad debe ser al menos 1")
    private Integer cantidad;

    private EstadoReservaServicio estado;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getReservaId() { return reservaId; }
    public void setReservaId(Integer reservaId) { this.reservaId = reservaId; }

    public Integer getServicioId() { return servicioId; }
    public void setServicioId(Integer servicioId) { this.servicioId = servicioId; }

    public String getNombreServicio() { return nombreServicio; }
    public void setNombreServicio(String nombreServicio) { this.nombreServicio = nombreServicio; }

    public Integer getEmpleadoId() { return empleadoId; }
    public void setEmpleadoId(Integer empleadoId) { this.empleadoId = empleadoId; }

    public String getNombreEmpleado() { return nombreEmpleado; }
    public void setNombreEmpleado(String nombreEmpleado) { this.nombreEmpleado = nombreEmpleado; }

    public LocalTime getHoraInicio() { return horaInicio; }
    public void setHoraInicio(LocalTime horaInicio) { this.horaInicio = horaInicio; }

    public LocalTime getHoraFin() { return horaFin; }
    public void setHoraFin(LocalTime horaFin) { this.horaFin = horaFin; }

    public BigDecimal getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(BigDecimal precioUnitario) { this.precioUnitario = precioUnitario; }

    public Integer getCantidad() { return cantidad; }
    public void setCantidad(Integer cantidad) { this.cantidad = cantidad; }

    public EstadoReservaServicio getEstado() { return estado; }
    public void setEstado(EstadoReservaServicio estado) { this.estado = estado; }
}