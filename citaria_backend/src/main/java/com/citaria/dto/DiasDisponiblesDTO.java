package com.citaria.dto;

import java.util.List;

/**
 * Respuesta del endpoint de días disponibles del mes.
 */
public class DiasDisponiblesDTO {

    private List<Integer> diasDisponibles;

    public DiasDisponiblesDTO(List<Integer> diasDisponibles) {
        this.diasDisponibles = diasDisponibles;
    }

    public List<Integer> getDiasDisponibles() { return diasDisponibles; }
}
