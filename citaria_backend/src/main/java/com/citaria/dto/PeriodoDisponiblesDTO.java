package com.citaria.dto;

import java.time.LocalDate;
import java.util.List;

public class PeriodoDisponiblesDTO {

    private List<LocalDate> fechasDisponibles;

    public PeriodoDisponiblesDTO(List<LocalDate> fechasDisponibles) {
        this.fechasDisponibles = fechasDisponibles;
    }

    public List<LocalDate> getFechasDisponibles() { return fechasDisponibles; }
}
