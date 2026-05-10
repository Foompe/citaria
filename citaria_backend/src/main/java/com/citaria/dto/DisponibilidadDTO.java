package com.citaria.dto;

import java.time.LocalDate;
import java.util.List;

/**
 * Respuesta del endpoint de disponibilidad.
 */
public class DisponibilidadDTO {

    private LocalDate fecha;
    private List<FranjaHorariaDTO> franjas;

    public DisponibilidadDTO(LocalDate fecha, List<FranjaHorariaDTO> franjas) {
        this.fecha = fecha;
        this.franjas = franjas;
    }

    public LocalDate getFecha() { return fecha; }
    public List<FranjaHorariaDTO> getFranjas() { return franjas; }
}