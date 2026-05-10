package com.citaria.dto;

import java.time.LocalTime;

/**
 * Representa una franja horaria libre para reservar.
 */
public class FranjaHorariaDTO {

    private LocalTime horaInicio;
    private LocalTime horaFin;
    private boolean disponible;
    private int empleadosDisponibles;

    public FranjaHorariaDTO(LocalTime horaInicio, LocalTime horaFin,
                            boolean disponible, int empleadosDisponibles) {
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.disponible = disponible;
        this.empleadosDisponibles = empleadosDisponibles;
    }

    public LocalTime getHoraInicio() { return horaInicio; }
    public LocalTime getHoraFin() { return horaFin; }
    public boolean isDisponible() { return disponible; }
    public int getEmpleadosDisponibles() { return empleadosDisponibles; }
}