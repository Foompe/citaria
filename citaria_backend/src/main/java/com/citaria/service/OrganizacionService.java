package com.citaria.service;

import com.citaria.dto.OrganizacionDTO;
import com.citaria.dto.ConfiguracionVisualDTO;
import com.citaria.dto.OrganizacionHorarioDTO;
import com.citaria.dto.OrganizacionHorarioCierreDTO;

import java.util.List;
import java.util.Optional;

/**
 * Contrato del servicio de gestión de organizaciones.
 * Incluye gestión de horarios, cierres y configuración visual.
 */
public interface OrganizacionService {

    // Organización
    List<OrganizacionDTO> obtenerTodas();
    Optional<OrganizacionDTO> obtenerPorId(Integer id);
    OrganizacionDTO crear(OrganizacionDTO dto);
    Optional<OrganizacionDTO> actualizar(Integer id, OrganizacionDTO dto);
    boolean eliminar(Integer id);

    // Configuración visual
    Optional<ConfiguracionVisualDTO> obtenerConfiguracionPorOrganizacion(Integer organizacionId);
    ConfiguracionVisualDTO crearConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto);
    Optional<ConfiguracionVisualDTO> actualizarConfiguracion(Integer organizacionId, ConfiguracionVisualDTO dto);

    // Horarios
    List<OrganizacionHorarioDTO> obtenerHorariosPorOrganizacion(Integer organizacionId);
    OrganizacionHorarioDTO crearHorario(Integer organizacionId, OrganizacionHorarioDTO dto);
    Optional<OrganizacionHorarioDTO> actualizarHorario(Integer id, OrganizacionHorarioDTO dto);
    boolean eliminarHorario(Integer id);

    // Cierres
    List<OrganizacionHorarioCierreDTO> obtenerCierresPorOrganizacion(Integer organizacionId);
    OrganizacionHorarioCierreDTO crearCierre(Integer organizacionId, OrganizacionHorarioCierreDTO dto);
    boolean eliminarCierre(Integer id);
}