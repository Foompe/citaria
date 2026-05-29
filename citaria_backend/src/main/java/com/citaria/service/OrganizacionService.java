package com.citaria.service;

import com.citaria.dto.ConfiguracionVisualDTO;
import com.citaria.dto.OrganizacionDTO;
import com.citaria.dto.OrganizacionHorarioCierreDTO;
import com.citaria.dto.OrganizacionHorarioDTO;
import com.citaria.dto.OrganizacionPublicaDTO;
import java.time.LocalDate;
import java.util.List;

/**
 * Servicio de gestión de organizaciones: horarios, cierres y configuración visual.
 */
public interface OrganizacionService {

    // Organización
    List<OrganizacionPublicaDTO> obtenerPublicas();
    OrganizacionDTO obtenerPorId(Integer id);
    OrganizacionDTO crear(OrganizacionDTO dto);
    OrganizacionDTO actualizar(Integer id, OrganizacionDTO dto);
    void eliminar(Integer id);

    // Configuración visual
    ConfiguracionVisualDTO obtenerConfiguracionPorToken(String tokenRegistro);
    ConfiguracionVisualDTO obtenerConfiguracionPublicaPorOrganizacionId(Integer organizacionId);
    ConfiguracionVisualDTO crearConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto);
    ConfiguracionVisualDTO actualizarConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto);

    // Horarios
    List<OrganizacionHorarioDTO> obtenerHorariosPorOrganizacion(Integer organizacionId);
    OrganizacionHorarioDTO crearHorario(Integer organizacionId, OrganizacionHorarioDTO dto);
    OrganizacionHorarioDTO actualizarHorario(Integer id, OrganizacionHorarioDTO dto);
    void eliminarHorario(Integer id);

    // Cierres
    List<OrganizacionHorarioCierreDTO> obtenerCierresPorOrganizacion(Integer organizacionId);
    OrganizacionHorarioCierreDTO crearCierre(Integer organizacionId, OrganizacionHorarioCierreDTO dto);
    void eliminarCierre(Integer id);
    int contarReservasActivasEnFecha(Integer organizacionId, LocalDate fecha);

}
