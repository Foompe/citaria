package com.citaria.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Objects;

/**
 * Hace referencia a cada una de las líneas de una reserva.
 */
@Entity
@Table(name = "reserva_servicio")
public class ReservaServicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reserva_id", nullable = false)
    private Reserva reserva;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servicio_id", nullable = false)
    private Servicio servicio;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "empleado_id", nullable = false)
    private Empleado empleado;

    @Column(name = "hora_inicio", nullable = false)
    private LocalTime horaInicio;

    @Column(name = "hora_fin", nullable = false)
    private LocalTime horaFin;

    @Column(name = "precio_unitario", nullable = false, precision = 10, scale = 2)
    private BigDecimal precioUnitario;

    @Column(nullable = false)
    private Integer cantidad = 1;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoReservaServicio estado = EstadoReservaServicio.activo;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Reserva getReserva() {
        return reserva;
    }

    public void setReserva(Reserva reserva) {
        this.reserva = reserva;
    }

    public Servicio getServicio() {
        return servicio;
    }

    public void setServicio(Servicio servicio) {
        this.servicio = servicio;
    }

    public Empleado getEmpleado() {
        return empleado;
    }

    public void setEmpleado(Empleado empleado) {
        this.empleado = empleado;
    }

    public LocalTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalTime horaInicio) {
        this.horaInicio = horaInicio;
    }

    public LocalTime getHoraFin() {
        return horaFin;
    }

    public void setHoraFin(LocalTime horaFin) {
        this.horaFin = horaFin;
    }

    public BigDecimal getPrecioUnitario() {
        return precioUnitario;
    }

    public void setPrecioUnitario(BigDecimal precioUnitario) {
        this.precioUnitario = precioUnitario;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public EstadoReservaServicio getEstado() {
        return estado;
    }

    public void setEstado(EstadoReservaServicio estado) {
        this.estado = estado;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ReservaServicio that)) return false;
        return Objects.equals(id, that.id) && Objects.equals(reserva, that.reserva) && Objects.equals(servicio, that.servicio) && Objects.equals(empleado, that.empleado) && Objects.equals(horaInicio, that.horaInicio) && Objects.equals(horaFin, that.horaFin) && Objects.equals(precioUnitario, that.precioUnitario) && Objects.equals(cantidad, that.cantidad) && estado == that.estado;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, reserva, servicio, empleado, horaInicio, horaFin, precioUnitario, cantidad, estado);
    }

    @Override
    public String toString() {
        return "ReservaServicio{" +
                "id=" + id +
                ", reservaId=" + (reserva != null ? reserva.getId() : null) +
                ", servicioId=" + (servicio != null ? servicio.getId() : null) +
                ", empleadoId=" + (empleado != null ? empleado.getId() : null) +
                ", horaInicio=" + horaInicio +
                ", horaFin=" + horaFin +
                ", precioUnitario=" + precioUnitario +
                ", cantidad=" + cantidad +
                ", estado=" + estado +
                '}';
    }
}